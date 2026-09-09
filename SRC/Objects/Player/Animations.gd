extends Node
class_name Animations

@export var animationsprite : AnimatedSprite3D
var parent : CharacterBody3D

# Bobbing Parameters
@export var bob_speed : float = 12.0
@export var bob_amount : float = 0.08

var default_y_pos : float = 0.0
var bob_time : float = 0.0

func _ready() -> void:
	parent = get_parent()
	if animationsprite:
		default_y_pos = animationsprite.position.y

func _process(delta: float) -> void:
	# 1. Flip Sprite
	if Input.is_action_pressed("walk_left"):
		animationsprite.scale.x = -1
	elif Input.is_action_pressed("walk_right"):
		animationsprite.scale.x = 1

	# 2. State & Animation Setup
	var is_moving : bool = parent.velocity.x != 0 or parent.velocity.z != 0
	var is_sprinting : bool = is_moving and Input.is_action_pressed("Sprint")

	if not parent.is_on_floor():
		animationsprite.speed_scale = 1.0
		if parent.velocity.y > 0:
			animationsprite.play("Jump")
		else:
			animationsprite.play("Fall")
		_reset_bobbing(delta)

	elif is_sprinting:
		animationsprite.play("Run")
		animationsprite.speed_scale = 1.8
		_apply_bobbing(delta, bob_speed * 1.5, bob_amount * 1.3)

	elif is_moving:
		animationsprite.play("Walk")
		animationsprite.speed_scale = 1.2
		_apply_bobbing(delta, bob_speed, bob_amount)

	else:
		animationsprite.play("Idle")
		animationsprite.speed_scale = 0.5
		_reset_bobbing(delta)

func _apply_bobbing(delta: float, speed: float, amount: float) -> void:
	bob_time += delta * speed
	var target_y : float = default_y_pos + sin(bob_time) * amount
	# Lerp smooths out sudden speed/amount changes between walk and sprint
	animationsprite.position.y = lerp(animationsprite.position.y, target_y, delta * 15.0)

func _reset_bobbing(delta: float) -> void:
	# Keep bob_time running so phase isn't lost if the player rapidly taps movement
	# Lerp smoothly brings the offset back to baseline
	animationsprite.position.y = lerp(animationsprite.position.y, default_y_pos, delta * 10.0)
