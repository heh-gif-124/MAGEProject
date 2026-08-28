extends CharacterBody3D
@onready var raycast = $RayCast3D
@onready var shadow = $Sprite3D # Or Sprite3D
@export var shadow_offset: float = 0.05
@export var max_distance: float = 10.0   # Distance where shadow completely vanishes/shrinks
@export var max_scale: float = 1.0       # Scale when touching the floor
@export var min_scale: float = 0.1       # Scale at maximum height

const SPEED = 5.0
const JUMP_VELOCITY = 8


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	

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
