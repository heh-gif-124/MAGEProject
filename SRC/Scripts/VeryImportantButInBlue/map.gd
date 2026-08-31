extends Node2D

@onready var camera: Camera2D = $Camera2D;

# Zoom settings
@export var zoom_scale: Vector2 = Vector2(2.5, 2.5); # 2.5x zoom
@export var def_zoom: Vector2 = Vector2(1.0, 1.0);    # Normal view
@export var trans_duration: float = 0.6;             # Time in seconds

var active_tween: Tween;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Auto-Connect input events for all sectors
	for sector in $Sectors.get_children():
		if (sector is Area2D):
			sector.input_event.connect(_on_input_sector.bind(sector));


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_input_sector(_viewport: Node, event: InputEvent, _shape_idx: int, sector: Area2D) -> void:
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
		print("Custom shape clicked!");
		zoom_to_pos(sector.global_position, zoom_scale);
		

# Smoothly interpolates the camera to a target location and zoom level
func zoom_to_pos(target_pos: Vector2, target_zoom: Vector2) -> void:
	# Cancels any leftover running zoom animation
	if (active_tween and active_tween.is_running()):
		active_tween.kill();

	# Tween Setup
	active_tween = create_tween();
	active_tween.set_parallel(true);
	## Ease 
	active_tween.set_trans(Tween.TRANS_CUBIC);
	active_tween.set_ease(Tween.EASE_OUT);
	
	# Camera Movement
	active_tween.tween_property(camera, "global_position", target_pos, trans_duration);
	active_tween.tween_property(camera, "zoom", target_zoom, trans_duration);
