extends Control

var started : bool = false
var won : bool = false

@export var win_area : Area2D
@export var mini_player : CharacterBody2D
@export var winlabel : Label
var hydrant : Area3D
var stylebox : StyleBoxFlat
@export var tape_stopped : bool = false
func _ready() -> void:

	Global.minigame.connect(func(hole):
		_reset_stuff()
		hydrant = hole
	)


func _physics_process(delta: float) -> void:
	if started == true:
		if Input.is_action_just_pressed("ui_right"):
			mini_player.velocity.x += 10
	if win_area.has_overlapping_bodies():
		if tape_stopped == true:
			won = true
			Global.minigames_completed += 1
			winlabel.visible = true
			await get_tree().create_timer(1.5, true, false, true).timeout
			Global.minigame_initiated = false
			Global.minigame_finished.emit.call_deferred()
			Global.currency += 100
			print("Money: " + str(Global.currency))
			visible = false
			hydrant.queue_free()
			queue_free()
			return
	mini_player.move_and_slide()
	if Input.is_action_just_pressed("interact"):
		mini_player.velocity.x = 0
		tape_stopped = true

func _reset_stuff():
	#use at the start of every minigame
	winlabel.visible = false
	mini_player.position = Vector2(-560.0,0)
	started = false
	won = false
	visible = true
	await get_tree().create_timer(0.5, true, false, true).timeout
	started = true
