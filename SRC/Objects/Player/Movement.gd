extends Node
class_name MainMovement
@export var player : CharacterBody3D
var SPEED = 3.0
var sprint_mult : float = 2


@export_group("Jump Feel")
@export var JUMP_VELOCITY: float = 7.0
@export var jump_cut_multiplier: float = 0.5 # Velocity multiplier when releasing jump early
@export var coyote_time: float = 0.15          # Grace period (seconds) to jump after leaving a ledge
@export var jump_buffer_time: float = 0.15     # Window (seconds) to queue a jump before hitting the ground
@export var gravity : float = 5.0

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	if direction:
		player.velocity.x = direction.x * SPEED
		player.velocity.z = direction.z * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, SPEED)

	if Input.is_action_pressed("Sprint"):
		SPEED = 4.0 * sprint_mult
	elif Input.is_action_just_released("Sprint"):
		SPEED = 3.0

		# Add the gravity.
	if player.is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

			# 2. Execute Jump (Checks Buffer & Coyote Time instead of direct floor check)
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		player.velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

			# 3. Variable Jump Height (Cut vertical velocity if released while ascending)
	if Input.is_action_just_released("ui_accept") and player.velocity.y < 0:
		player.velocity.y *= jump_cut_multiplier
