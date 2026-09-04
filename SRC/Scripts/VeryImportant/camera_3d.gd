class_name Camera2D5
extends Camera3D

@export_group("Target Tracking")
@export var target: Node3D
@export var follow_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 8, 12)
@export var look_at_offset: Vector3 = Vector3(0, 1, 0)

@export_group("Mouse Tilt")
@export var max_tilt_angle: Vector2 = Vector2(deg_to_rad(5.0), deg_to_rad(5.0)) # Pitch (X) and Yaw (Y) limits
@export var tilt_speed: float = 5.0

@export_group("Screen Shake")
@export var max_shake_offset: Vector3 = Vector3(0.5, 0.5, 0)
@export var max_shake_roll: float = 0.1
@export var shake_decay: float = 3.0

var shake_intensity: float = 0.0
var noise := FastNoiseLite.new()
var noise_y: float = 0.0
var current_tilt := Vector2.ZERO

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.2

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	# Smooth Position Following
	var target_pos := target.global_position + offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	# Base Look At
	look_at(target.global_position + look_at_offset, Vector3.UP)

	# Mouse Tilt Calculation
	_apply_mouse_tilt(delta)

	# Handle Screen Shake Decay
	if shake_intensity > 0:
		shake_intensity = max(shake_intensity - shake_decay * delta, 0.0)
		_apply_shake()

func add_shake(amount: float) -> void:
	shake_intensity = clamp(shake_intensity + amount, 0.0, 1.0)

func _apply_mouse_tilt(delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x == 0 or viewport_size.y == 0:
		return

	# Get mouse coordinates normalized from -1.0 to 1.0 (Center is 0,0)
	var mouse_pos := get_viewport().get_mouse_position()
	var normalized_mouse := Vector2(
		(mouse_pos.x / viewport_size.x) * 2.0 - 1.0,
		(mouse_pos.y / viewport_size.y) * 2.0 - 1.0
	)
	normalized_mouse = normalized_mouse.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))

	# Target rotation offset based on mouse location
	var target_tilt := Vector2(
		-normalized_mouse.y * max_tilt_angle.x, # Pitch (look up/down)
		-normalized_mouse.x * max_tilt_angle.y  # Yaw (look left/right)
	)

	# Smooth interpolation
	current_tilt = current_tilt.lerp(target_tilt, tilt_speed * delta)

	# Apply local rotation on top of look_at()
	rotate_object_local(Vector3.RIGHT, current_tilt.x)
	rotate_object_local(Vector3.UP, current_tilt.y)

func _apply_shake() -> void:
	noise_y += 1.0
	var shake_val := shake_intensity * shake_intensity # Exponential dropoff

	var offset_x := max_shake_offset.x * shake_val * noise.get_noise_2d(noise.seed, noise_y)
	var offset_y := max_shake_offset.y * shake_val * noise.get_noise_2d(noise.seed + 1, noise_y)
	var offset_z := max_shake_offset.z * shake_val * noise.get_noise_2d(noise.seed + 2, noise_y)
	var roll := max_shake_roll * shake_val * noise.get_noise_2d(noise.seed + 3, noise_y)

	h_offset = offset_x
	v_offset = offset_y
	rotation.z += roll
