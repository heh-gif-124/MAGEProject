extends Node
class_name MainMovement

@export var player : CharacterBody3D
var SPEED = 3.0
var sprint_mult : float = 2
var can_double : bool = true

@export_group("Jump Feel")
@export var JUMP_VELOCITY: float = 7.0
@export var double_jump_velocity: float = 6.0 # Height of the air jump
@export var jump_cut_multiplier: float = 0.5
@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.15
@export var gravity : float = 5.0

@export_group("Abilities")
@export var dashing_unlocked: bool = false # When true, sprint is locked and dash is enabled
@export var dash_speed: float = 12.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

@export_group("Visual Effects")
@export var camera : Camera3D
@export var normal_fov : float = 75.0
@export var sprint_fov : float = 82.0
@export var dash_fov : float = 95.0
@export var fov_lerp_speed : float = 12.0
@export var dash_particles : GPUParticles3D # Optional: Attach a particle node here for a dash burst

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# Dash runtime variables
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	if camera:
		normal_fov = camera.fov

func _process(delta: float) -> void:
	# 1. Handle Cooldowns & Timers
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Track whether player is actively sprinting for effects
	var is_sprinting : bool = false
	if Global.minigame_initiated == false:
		# 2. Handle Dash vs Sprint Mutually Exclusive Inputs
		if Global.dashing_unlocked:
			# Sprint is locked out; check for Dash input instead
			if Input.is_action_just_pressed("Sprint") and not is_dashing and dash_cooldown_timer <= 0.0:
				if direction != Vector3.ZERO:
					dash_direction = direction
				else:
					dash_direction = -player.transform.basis.z

				is_dashing = true
				dash_timer = dash_duration
				dash_cooldown_timer = dash_cooldown

				# Trigger particle effect if assigned
				if dash_particles:
					dash_particles.restart()
					dash_particles.emitting = true
		else:
			# Dash is locked; normal Sprint behavior applies
			if Input.is_action_pressed("Sprint"):
				SPEED = 3.0 * sprint_mult
				is_sprinting = true
			elif Input.is_action_just_released("Sprint"):
				SPEED = 3.0

		# 3. Handle Dynamic Camera FOV Effects
		if camera:
			var target_fov = normal_fov
			if is_dashing:
				target_fov = dash_fov
			elif is_sprinting:
				target_fov = sprint_fov

			camera.fov = lerp(camera.fov, target_fov, fov_lerp_speed * delta)

		# 4. Movement Logic (Dash overrides normal movement)
		if is_dashing:
			dash_timer -= delta
			player.velocity.x = dash_direction.x * dash_speed
			player.velocity.z = dash_direction.z * dash_speed

			if dash_timer <= 0.0:
				is_dashing = false
		else:
			# Standard movement & gravity
			if not player.is_on_floor():
				player.velocity += player.get_gravity() * delta

			if direction:
				player.velocity.x = direction.x * SPEED
				player.velocity.z = direction.z * SPEED
			else:
				player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
				player.velocity.z = move_toward(player.velocity.z, 0, SPEED)

			# Coyote Time tracking & Floor Reset
			if player.is_on_floor():
				coyote_timer = coyote_time
				can_double = true # Reset double jump when landing
			else:
				coyote_timer -= delta

			# Jump Buffer tracking
			if Input.is_action_just_pressed("jump"):
				jump_buffer_timer = jump_buffer_time
			else:
				jump_buffer_timer -= delta

			# Execute Ground Jump
			if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
				player.velocity.y = JUMP_VELOCITY
				jump_buffer_timer = 0.0
				coyote_timer = 0.0
			# Execute Double Jump (Air Jump)
			elif jump_buffer_timer > 0.0 and Global.unlocked_double_jump and can_double and not player.is_on_floor():
				player.velocity.y = double_jump_velocity
				can_double = false
				jump_buffer_timer = 0.0

			# Variable Jump Height
			if Input.is_action_just_released("ui_accept") and player.velocity.y < 0:
				player.velocity.y *= jump_cut_multiplier
	elif Global.minigame_initiated == true:
		player.velocity = Vector3(0,0,0)
