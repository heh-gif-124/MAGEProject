extends Node
class_name MainMovement

@export var player : CharacterBody3D

@export_group("Movement Settings")
@export var base_speed : float = 3.0
@export var sprint_multiplier : float = 2.0

@export_group("Jump Feel")
@export var jump_velocity: float = 7.0
@export var double_jump_velocity: float = 6.0
@export var jump_cut_multiplier: float = 0.5
@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.15

@export_group("Abilities")
@export var dashing_unlocked: bool = false
@export var dash_speed: float = 12.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

@export_group("Visual Effects")
@export var camera : Camera3D
@export var normal_fov : float = 75.0
@export var sprint_fov : float = 82.0
@export var dash_fov : float = 95.0
@export var fov_lerp_speed : float = 12.0
@export var dash_particles : GPUParticles3D

# Internal State Tracking
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var can_double_jump: bool = false

# Dash runtime variables
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	if camera:
		normal_fov = camera.fov

func _process(delta: float) -> void:
	# Freeze movement during minigames
	if Global.minigame_initiated:
		player.velocity = Vector3.ZERO
		return

	# --- 1. TIMERS & INPUT COLLECTION ---
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# --- 2. ABILITY: DASH VS SPRINT ---
	var current_speed = base_speed
	var is_sprinting = false

	if Global.dashing_unlocked:
		if Input.is_action_just_pressed("Sprint") and not is_dashing and dash_cooldown_timer <= 0.0:
			dash_direction = direction if direction != Vector3.ZERO else -player.transform.basis.z
			is_dashing = true
			dash_timer = dash_duration
			dash_cooldown_timer = dash_cooldown

			if dash_particles:
				dash_particles.restart()
				dash_particles.emitting = true
	else:
		if Input.is_action_pressed("Sprint"):
			current_speed = base_speed * sprint_multiplier
			is_sprinting = true

	# --- 3. CAMERA FOV EFFECTS ---
	if camera:
		var target_fov = normal_fov
		if is_dashing:
			target_fov = dash_fov
		elif is_sprinting:
			target_fov = sprint_fov
		camera.fov = lerp(camera.fov, target_fov, fov_lerp_speed * delta)

	# --- 4. MOVEMENT & GRAVITY EXECUTION ---
	if is_dashing:
		dash_timer -= delta
		player.velocity.x = dash_direction.x * dash_speed
		player.velocity.z = dash_direction.z * dash_speed
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		# Gravity
		if not player.is_on_floor():
			player.velocity += player.get_gravity() * delta

		# Horizontal Motion
		if direction:
			player.velocity.x = direction.x * current_speed
			player.velocity.z = direction.z * current_speed
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, current_speed)
			player.velocity.z = move_toward(player.velocity.z, 0, current_speed)

		# --- 5. REVISED JUMP SYSTEM ---
		# Floor and Coyote state tracking
		if player.is_on_floor():
			coyote_timer = coyote_time
			can_double_jump = true # Reset double jump rights on ground contact
		else:
			coyote_timer -= delta

		# Check for Ground Jump (using buffer + coyote window)
		var can_ground_jump = coyote_timer > 0.0
		var can_air_jump = not player.is_on_floor() and coyote_timer <= 0.0 and Global.unlocked_double_jump and can_double_jump

		if jump_buffer_timer > 0.0:
			if can_ground_jump:
				# Execute Ground Jump
				player.velocity.y = jump_velocity
				jump_buffer_timer = 0.0
				coyote_timer = 0.0 # Consume coyote time
				can_double_jump = true
			elif can_air_jump:
				# Execute Double Jump
				player.velocity.y = double_jump_velocity
				jump_buffer_timer = 0.0
				can_double_jump = false # Consume double jump capability

		# Variable Jump Height (Short Hop cut)
		if Input.is_action_just_released("jump") and player.velocity.y > 0.0:
			player.velocity.y *= jump_cut_multiplier
