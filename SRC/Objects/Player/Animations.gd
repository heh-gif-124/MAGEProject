extends Node
class_name Animations

@export var animationsprite : AnimatedSprite3D
@export var parent : CharacterBody3D

# Bobbing Parameters
@export var bob_speed : float = 12.0
@export var bob_amount : float = 0.08

# Turn / Flip Smoothness
@export var turn_speed : float = 15.0
var target_scale_x : float = 1.0

# Dynamic Juice / Squash & Stretch Parameters
@export_group("Juice Settings")
@export var squash_amount : Vector3 = Vector3(1.3, 0.7, 1.3) # Horizontal stretch on land/takeoff
@export var stretch_amount : Vector3 = Vector3(0.7, 1.3, 0.7) # Vertical stretch while rising
@export var juice_recovery_speed : float = 12.0 # Speed of returning to normal scale
@export var tilt_amount : float = 0.15 # Forward/backward tilt during air movement

var default_y_pos : float = 0.0
var bob_time : float = 0.0
var default_scale : Vector3 = Vector3.ONE
var was_on_floor : bool = true

func _ready() -> void:
	if animationsprite:
		default_y_pos = animationsprite.position.y
		target_scale_x = animationsprite.scale.x
		default_scale = animationsprite.scale

func _process(delta: float) -> void:
	if not animationsprite or not parent:
		return

	# 1. Flip Sprite (Smooth Interpolation)
	if Input.is_action_pressed("walk_left"):
		target_scale_x = -1.0
	elif Input.is_action_pressed("walk_right"):
		target_scale_x = 1.0

	# 2. State & Animation Setup
	var is_moving : bool = parent.velocity.x != 0 or parent.velocity.z != 0
	var is_sprinting : bool = is_moving and Input.is_action_pressed("sprint")
	var is_on_floor : bool = parent.is_on_floor()

	# --- JUMP JUICE DETECTORS ---
	# Takeoff Impact (Jump Triggered)
	if was_on_floor and not is_on_floor and parent.velocity.y > 0:
		_apply_squash_and_stretch(stretch_amount)

	# Landing Impact
	if not was_on_floor and is_on_floor:
		_apply_squash_and_stretch(squash_amount)

	was_on_floor = is_on_floor

	# 3. Air vs Ground States
	if not is_on_floor:
		animationsprite.speed_scale = 1.0
		if parent.velocity.y > 0:
			animationsprite.play("Jump")
		else:
			animationsprite.play("Fall")
		_reset_bobbing(delta)
		_apply_air_tilt(delta)

	elif is_sprinting:
		animationsprite.play("Run")
		animationsprite.speed_scale = 1.8
		_apply_bobbing(delta, bob_speed * 1.5, bob_amount * 1.3)
		_reset_tilt(delta)

	elif is_moving:
		animationsprite.play("Walk")
		animationsprite.speed_scale = 1.2
		_apply_bobbing(delta, bob_speed, bob_amount)
		_reset_tilt(delta)

	elif Global.dashing_unlocked == true and Input.is_action_just_pressed("Sprint"):
		animationsprite.play("Dashing")
		_reset_tilt(delta)
	else:
		animationsprite.play("Idle")
		animationsprite.speed_scale = 0.5
		_reset_bobbing(delta)
		_reset_tilt(delta)

	# 4. Smoothly recover scale back to base (retaining flip direction)
	_recover_juice_scale(delta)

func _apply_squash_and_stretch(target_scale: Vector3) -> void:
	# Keep the directional sign (+ or -) on X scale
	var current_sign_x : float = sign(animationsprite.scale.x)
	if current_sign_x == 0:
		current_sign_x = 1.0

	animationsprite.scale = Vector3(
		target_scale.x * current_sign_x,
		target_scale.y,
		target_scale.z
	)

func _recover_juice_scale(delta: float) -> void:
	var base_target_x : float = abs(default_scale.x) * target_scale_x
	var target_vec : Vector3 = Vector3(base_target_x, default_scale.y, default_scale.z)
	animationsprite.scale = animationsprite.scale.lerp(target_vec, delta * juice_recovery_speed)

func _apply_air_tilt(delta: float) -> void:
	# Tilts the sprite slightly in the direction of horizontal movement
	var move_dir : float = parent.velocity.x
	var target_rotation_z : float = -move_dir * tilt_amount * 0.1
	animationsprite.rotation.z = lerp(animationsprite.rotation.z, target_rotation_z, delta * 10.0)

func _reset_tilt(delta: float) -> void:
	animationsprite.rotation.z = lerp(animationsprite.rotation.z, 0.0, delta * 12.0)

func _apply_bobbing(delta: float, speed: float, amount: float) -> void:
	bob_time += delta * speed
	var target_y : float = default_y_pos + sin(bob_time) * amount
	animationsprite.position.y = lerp(animationsprite.position.y, target_y, delta * 15.0)

func _reset_bobbing(delta: float) -> void:
	animationsprite.position.y = lerp(animationsprite.position.y, default_y_pos, delta * 10.0)
