extends Node2D

@onready var camera: Camera2D = $Camera2D;

# Zoom settings
@export var camera_pos: Vector2 = Vector2.ZERO;      # Camera default position
@export var def_zoom: Vector2 = Vector2(1.0, 1.0);   # Normal view
@export var trans_duration: float = 0.6;             # Time in seconds
@export var padding_factor: float = 1.15;            # 15% margin around shape

# Hover settings
@export var hover_color: Color = Color(1.0, 1.0, 0.0, 0.35); # Semi-transparent yellow
@export var idle_color: Color = Color(1.0, 1.0, 1.0, 0.35);  # Semi-transparent white

@onready var level_overview: Control = $CanvasLayer/Level_Overview;
@onready var map_button: Button = $CanvasLayer/Level_Overview/City;
@onready var start_button: Button = $CanvasLayer/Level_Overview/Start;
@onready var clopen_button: Button = $CanvasLayer/Level_Overview/Clopen;
@onready var title_region: RichTextLabel = $CanvasLayer/Level_Overview/Region_Title;

enum UIState { INACTIVE = 0, OPEN = 1, CLOSED = -1 }
var clopen_state: UIState = UIState.INACTIVE

var cam_tween: Tween;
var ui_tween: Tween;
var active_poly: CollisionPolygon2D = null;
var hidden_x_pos: float = 0.0;
var visible_x_pos: float = 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# > Camera <
	
	# Auto-Connect input events for all regions
	for region in $Regions.get_children():
		if (region is Area2D):
			var poly = region.get_node_or_null("CollisionPolygon2D");
			if (poly || !poly.polygon.is_empty()):
				region.input_event.connect(_on_input_region.bind(poly));
				region.mouse_entered.connect(_on_region_mouse_entered.bind(poly));
				region.mouse_exited.connect(_on_region_mouse_exited.bind(poly));
				_create_hover_overlay(poly);
	
	
	# > UI <
	
	# Store the visible & hidden position
	visible_x_pos = level_overview.position.x;
	hidden_x_pos = level_overview.position.x + level_overview.size.x;
	
	# Move it off-screen at start
	level_overview.position.x = hidden_x_pos;
	
	# Connect buttons
	## start_button.pressed.connect(enter_level);
	map_button.pressed.connect(reset_camera);
	clopen_button.pressed.connect(clopen);
	clopen_state = UIState.INACTIVE;
	clopen_button.disabled = true;
	clopen_button.hide();

# Region inputs
func _on_input_region(_viewport: Node, event: InputEvent, _shape_idx: int, poly: CollisionPolygon2D) -> void:
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
		active_poly = poly; # Store active selection
		zoom_to_region(poly, Vector2(level_overview.size.x, 0));
		# Slide UI on-screen
		show_level_overview();

# Full camera inputs
func _unhandled_input(event: InputEvent) -> void:
	# Triggers on Escape key or Right-CLick
	var is_cancel_key = event.is_action_pressed("ui_cancel");
	var is_right_click = (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT 
	&& event.pressed);

	if (is_cancel_key || is_right_click):
		reset_camera();


# > Camera Control <

# Calculates bounding box in world space and triggers zoom
func zoom_to_region(poly: CollisionPolygon2D, ex_padding: Vector2 = Vector2.ZERO) -> void:
	if (!active_poly): return
	
	# Updates the Title of the Region
	title_region.text = active_poly.get_parent().name;
	
	# Calculate global bounding box of the polygon
	var points = poly.polygon;
	var first_global_point = poly.to_global(points[0]);
	var global_rect = Rect2(first_global_point, Vector2.ZERO);
	
	for point in points:
		global_rect = global_rect.expand(poly.to_global(point));
	
	# Get target center position
	var target_center = global_rect.get_center() + ex_padding;
	
	# Calculate required zoom scale based on viewport size
	var viewport_size = get_viewport_rect().size;
	var shape_size = global_rect.size * padding_factor + ex_padding;
	
	# Handle edge cases (zero size)
	if (shape_size.x <= 0 || shape_size.y <= 0):
		return;
	
	# Determine scale factor (pick the smaller zoom so both width and height fit)
	var zoom_x = viewport_size.x / shape_size.x;
	var zoom_y = viewport_size.y / shape_size.y;
	var target_zoom_level = min(zoom_x, zoom_y);

	var target_zoom = Vector2(target_zoom_level, target_zoom_level);
	
	# Offset center so region isn't covered by the UI panel
	if ex_padding.x != 0.0:
		target_center.x -= (ex_padding.x / 2.0) / target_zoom.x

	# Animate camera
	zoom_to_pos(target_center, target_zoom);

# Resets camera position and zoom back to default exported values
func reset_camera() -> void:
	# Zoom in on default
	active_poly = null;
	zoom_to_pos(camera_pos, def_zoom);
	
	# Slide UI back off-screen
	hide_level_overview();
	
	# Wait until the UI panel finishes moving off-screen
	if ui_tween && ui_tween.is_running():
		await ui_tween.finished;
	
	# Only reset text if no new region was clicked during the slide
	if (active_poly == null):
		title_region.text = "region_null_undisplayed";
	
	# Fully deactivates button on map overview
	clopen_state = UIState.INACTIVE;
	clopen_button.disabled = true;
	clopen_button.hide();

# Smoothly interpolates the camera to a target location and zoom level
func zoom_to_pos(target_pos: Vector2, target_zoom: Vector2) -> void:
	# Cancels any leftover running zoom animation
	if (cam_tween && cam_tween.is_running()):
		cam_tween.kill();

	# Tween Setup
	cam_tween = create_tween();
	cam_tween.set_parallel(true);
	## Ease 
	cam_tween.set_trans(Tween.TRANS_CUBIC);
	cam_tween.set_ease(Tween.EASE_OUT);
	
	# Camera Movement
	cam_tween.tween_property(camera, "global_position", target_pos, trans_duration);
	cam_tween.tween_property(camera, "zoom", target_zoom, trans_duration);


# > Region Overlay <

# Spawns a Polygon2D child that matches the collision shape
func _create_hover_overlay(poly: CollisionPolygon2D) -> void:

	var overlay = Polygon2D.new();
	overlay.name = "Overlay";
	overlay.polygon = poly.polygon;
	overlay.color = idle_color;
	poly.add_child(overlay);

# Hover Signal Handlers
func _on_region_mouse_entered(poly: CollisionPolygon2D) -> void:
	var overlay = poly.get_node_or_null("Overlay");
	if (overlay):
		overlay.color = hover_color;

func _on_region_mouse_exited(poly: CollisionPolygon2D) -> void:
	var overlay = poly.get_node_or_null("Overlay");
	if (overlay):
		overlay.color = idle_color;


# > UI <

# Toggles panel state when button is pressed
func clopen() -> void:
	if (!active_poly):
		return;

	if (clopen_state == UIState.OPEN):
		hide_level_overview();
		# Re-center camera back onto full viewport without panel offset
		zoom_to_region(active_poly, Vector2.ZERO);
	else:
		show_level_overview();
		# Shift camera to make room for panel
		zoom_to_region(active_poly, Vector2(level_overview.size.x, 0));

# Slide UI in from the left
func show_level_overview() -> void:
	if (ui_tween && ui_tween.is_running()):
		ui_tween.kill();
	
	# Activates button in open state
	clopen_state = UIState.OPEN;
	clopen_button.show();
	clopen_button.text = ">";
	clopen_button.disabled = true; # Lock during movement
	
	ui_tween = create_tween();
	ui_tween.set_trans(Tween.TRANS_CUBIC);
	ui_tween.set_ease(Tween.EASE_OUT);
	ui_tween.tween_property(level_overview, "position:x", visible_x_pos, trans_duration);
	
	ui_tween.tween_callback(func(): clopen_button.disabled = false);

# Slide UI back off-screen to the left
func hide_level_overview() -> void:
	if (ui_tween && ui_tween.is_running()):
		ui_tween.kill();
	
	
	# Button in closed state
	clopen_state = UIState.CLOSED
	clopen_button.text = "<"
	clopen_button.disabled = true; # Lock during movement
	
	ui_tween = create_tween();
	ui_tween.set_trans(Tween.TRANS_CUBIC);
	ui_tween.set_ease(Tween.EASE_OUT);
	ui_tween.tween_property(level_overview, "position:x", hidden_x_pos, trans_duration);
	
	# Unlocks button only when the UI panel finishes moving off-screen
	ui_tween.tween_callback(func(): clopen_button.disabled = false);
