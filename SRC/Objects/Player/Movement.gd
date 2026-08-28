extends Node
class_name MainMovement
@export var player : CharacterBody3D
var SPEED = 6.0
const JUMP_VELOCITY = 4.5
var sprint_mult : float = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = direction.x * SPEED
		player.velocity.z = direction.z * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, SPEED)
	
	if Input.is_action_pressed("Sprint"):
		SPEED = 6.0 * sprint_mult
	elif Input.is_action_just_released("Sprint"):
		SPEED = 6.0