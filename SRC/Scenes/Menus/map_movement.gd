extends TextureRect

const SAVE_PATH: String = "user://SaveFiles/config.cfg"

@export_group("Move Settings")
@export var move_speed: float = 900.0

@export_group("Zoom Settings")
@export var zoom_to_cursor: bool = true ## If true, zooms toward the mouse. If false, zooms toward the center of the screen.
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5  # How far out they can zoom
@export var max_zoom: float = 3  # How far in they can zoom

func _ready() -> void:
	_load_zoom_preference()
	position = size / 2
	if zoom_to_cursor:
		mouse_default_cursor_shape = Control.CURSOR_CROSS

func _exit_tree() -> void:
	# Reset cursor back to default when leaving the map scene
	Input.set_custom_mouse_cursor(null)

func _process(delta: float) -> void:
	# Get WASD / Arrow input direction
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	
	# Pressing 'Right' moves the map to the left so you can see what's on the right side.
	position -= input_dir * move_speed * delta
	
	_clamp_map_position()

func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse wheel scrolling for zooming
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(1.0 + zoom_speed)
			accept_event() # Marks input as handled so buttons underneath don't glitch
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(1.0 - zoom_speed)
			accept_event()

func _apply_zoom(zoom_factor: float) -> void:
	var old_scale = scale
	
	# Calculate new scale and clamp it between min and max limits
	var new_scale_x = clamp(scale.x * zoom_factor, min_zoom, max_zoom)
	var new_scale_y = clamp(scale.y * zoom_factor, min_zoom, max_zoom)
	var new_scale = Vector2(new_scale_x, new_scale_y)
	
	if new_scale == old_scale:
		return
		
	# Determine the pivot point based on the toggle setting
	var pivot_point: Vector2 
	if zoom_to_cursor:
		pivot_point = get_viewport().get_mouse_position()
	else:
		pivot_point = get_viewport_rect().size / 2.0
	
	# Figure out what exact point on the map the mouse is currently hovering over
	var local_pivot = (pivot_point - position) / old_scale
	scale = new_scale
	position = pivot_point - (local_pivot * scale)
	
	# Immediately clamp position in case zooming made the map smaller than the viewport
	_clamp_map_position()

func _clamp_map_position() -> void:
	var viewport_size = get_viewport_rect().size
	
	# Calculate the actual rendered size of the map
	var map_size = size * scale
	
	# If the map is larger than the screen, allow panning within bounds.
	# If it's smaller, lock it in place.
	var min_x = min(0.0, viewport_size.x - map_size.x)
	var max_x = 0.0
	
	var min_y = min(0.0, viewport_size.y - map_size.y)
	var max_y = 0.0
	
	position.x = clamp(position.x, min_x, max_x)
	position.y = clamp(position.y, min_y, max_y)

func _load_zoom_preference() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		# Read the setting, default to true if it hasn't been saved yet
		zoom_to_cursor = config.get_value("game", "cursor_zoom", true)
