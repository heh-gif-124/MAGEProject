class_name Camera2D5
extends Camera3D

@export_group("Target Tracking")
@export var target: Node3D
@export var follow_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 8, 12)
@export var look_at_offset: Vector3 = Vector3(0, 1, 0)

@export_group("Screen Shake")
@export var max_shake_offset: Vector3 = Vector3(0.5, 0.5, 0)
@export var max_shake_roll: float = 0.1
@export var shake_decay: float = 3.0

var shake_intensity: float = 0.0
var noise := FastNoiseLite.new()
var noise_y: float = 0.0

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.2

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	# Smooth Position Following
	var target_pos := target.global_position + offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	# Look at Target
	look_at(target.global_position + look_at_offset, Vector3.UP)

	# Handle Screen Shake Decay
	if shake_intensity > 0:
		shake_intensity = max(shake_intensity - shake_decay * delta, 0.0)
		_apply_shake()

func add_shake(amount: float) -> void:
	shake_intensity = clamp(shake_intensity + amount, 0.0, 1.0)

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