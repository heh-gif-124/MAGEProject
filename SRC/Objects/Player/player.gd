extends CharacterBody3D
@onready var raycast = $RayCast3D
@onready var shadow = $Sprite3D # Or Sprite3D
@export_group("Shadow stuff")
@export var shadow_offset: float = 0.05
@export var max_distance: float = 10.0   # Distance where shadow completely vanishes/shrinks
@export var max_scale: float = 1.0       # Scale when touching the floor
@export var min_scale: float = 0.1       # Scale at maximum height

@export_group("Jump Feel")
@export var JUMP_VELOCITY: float = 7.0
@export var jump_cut_multiplier: float = 0.5 # Velocity multiplier when releasing jump early
@export var coyote_time: float = 0.15          # Grace period (seconds) to jump after leaving a ledge
@export var jump_buffer_time: float = 0.15     # Window (seconds) to queue a jump before hitting the ground

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

const SPEED = 5.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
			coyote_timer = coyote_time
	else:
			coyote_timer -= delta

	if Input.is_action_just_pressed("ui_accept"):
			jump_buffer_timer = jump_buffer_time
	else:
			jump_buffer_timer -= delta

		# 2. Execute Jump (Checks Buffer & Coyote Time instead of direct floor check)
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0.0
			coyote_timer = 0.0

		# 3. Variable Jump Height (Cut vertical velocity if released while ascending)
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
			velocity.y *= jump_cut_multiplier
	move_and_slide()


func _process(_delta: float) -> void:
	if raycast.is_colliding():
		shadow.visible = true

		# 1. Position Shadow slightly above ground
		var hit_point = raycast.get_collision_point()
		hit_point.y += shadow_offset
		shadow.global_position = hit_point

		# 2. Calculate Distance & Scale Factor
		var current_distance = raycast.global_position.distance_to(hit_point)
		var scale_factor = remap(current_distance, 0.0, max_distance, max_scale, min_scale)
		scale_factor = clamp(scale_factor, min_scale, max_scale)

		# 3. Apply Scale (preserves Y or scales uniformly)
		shadow.scale = Vector3(scale_factor, scale_factor, scale_factor)
	else:
		shadow.visible = false
