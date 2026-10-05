extends Node
class_name GameHandler
@export_group("Holes")
@export var hole_placer : HolePlacer
@export var hole_container : Node3D
@export_group("UI")
@export var UI_layer : CanvasLayer
@export_subgroup("Countdown")
@export var countdown : Timer
@export var countdown_label : Label
@export_subgroup("next Level")
@export var next_level : PackedScene
@export_subgroup("waves")
@export var waves : int = 3
@export var waveui : Control
@export var animation_player : AnimationPlayer
@export var respawn_floor : Area3D
@export var moneylabel : Label
@export_group("Shop")
@export var shop_ui : PackedScene
var in_minigame : bool = false
var minigames_needed : int
var won_already : bool = false
var current_wave : int = 1
var shop_phase : bool = false

func _ready() -> void:

	Global.minigame_finished.connect(func():
		if hole_container.get_child_count() <= 0 and current_wave <= waves:
			hole_placer._place_holes()
			current_wave += 1
			print("YOU WIN!!")
	)
	if respawn_floor != null:
		respawn_floor.body_entered.connect(func(body):
			if body.is_in_group("Player"):
				body.global_position = Vector3(0.233,1.251,-0.359)
		)



func _physics_process(delta: float) -> void:
	moneylabel.text = "$"+str(Global.currency)
	countdown_label.text = "⏱: " + str(int(ceil(countdown.time_left)))
	if current_wave > waves and shop_phase == false:
		shop_phase = true
		var yt = shop_ui.instantiate()
		UI_layer.add_child.call_deferred(yt)



func _start_new_wave():
	hole_placer._place_holes()
