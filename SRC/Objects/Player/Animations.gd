extends Node
class_name Animations

@export var animationsprite : AnimatedSprite3D
var parent : CharacterBody3D

func _ready() -> void:
	parent = get_parent()

func _process(_delta: float) -> void:
	# 1. Flip Sprite (using scale or flip_h)
	if Input.is_action_pressed("walk_left"):
		animationsprite.scale.x = -1
	elif Input.is_action_pressed("walk_right"):
		animationsprite.scale.x = 1

	# 2. Priority State Management
	if not parent.is_on_floor():
		animationsprite.speed_scale = 1.0
		if parent.velocity.y > 0:
			animationsprite.play("Jump")
		else:
			animationsprite.play("Fall")

	elif parent.velocity.x != 0 or parent.velocity.z != 0:
		animationsprite.play("Walk")
		animationsprite.speed_scale = 1.5
	else:
		animationsprite.play("Idle")
		animationsprite.speed_scale = 0.5
