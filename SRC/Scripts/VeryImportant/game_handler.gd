extends Node
class_name GameHandler

@export_group("Holes")
@export var hole_placer : HolePlacer
@export var hole_container : Node3D

@export_group("UI")
@export var UI_layer : CanvasLayer

@export_subgroup("Countdown")
@export var countdown : Timer
@export var countdown_bar : ProgressBar # Replaced Label with ProgressBar

@export_subgroup("Water Hazard")
@export var water_node : Node3D         # Drag your water mesh/node here
@export var water_min_y : float = -2.0  # Height when countdown starts
@export var water_max_y : float = 3.0  # Height when countdown hits 0
@export var move_respawn_floor_with_water : bool = true

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

@export_group("Game Over Screen")
@export var gos : PackedScene

func _ready() -> void:
	# Initialize the progress bar max value to match the timer's total duration
	if countdown != null and countdown_bar != null:
		countdown_bar.max_value = countdown.wait_time

	# Initialize water position at the start
	if water_node != null:
		var pos = water_node.global_position
		pos.y = water_min_y
		water_node.global_position = pos

	Global.minigame_finished.connect(func():
		_start_new_wave()
	)

	if respawn_floor != null:
		respawn_floor.body_entered.connect(func(body):
			if body.is_in_group("Player"):
				body.global_position = Vector3(0.233, 1.251, -0.359)
		)

	countdown.timeout.connect(func():
		var gtt = gos.instantiate()
		UI_layer.add_child.call_deferred(gtt)
	)

	Global.shop_exited.connect(func():
		await get_tree().create_timer(1.5, true, false, true).timeout
		get_tree().change_scene_to_packed(next_level)
	)

func _physics_process(delta: float) -> void:
	if moneylabel != null:
		moneylabel.text = "$" + str(Global.currency)

	# Update the progress bar value with the timer's remaining time
	if countdown_bar != null and countdown != null:
		countdown_bar.value = countdown.time_left

	# --- RISING WATER LOGIC ---
	if countdown != null and not countdown.is_stopped() and countdown.wait_time > 0:
		# Calculates progress from 0.0 (start) to 1.0 (when timer reaches 0)
		var time_ratio = 1.0 - (countdown.time_left / countdown.wait_time)

		if water_node != null:
			var target_y = lerp(water_min_y, water_max_y, time_ratio)
			var water_pos = water_node.global_position
			water_pos.y = target_y
			water_node.global_position = water_pos

			# Optionally move the respawn floor up with the water so the kill plane stays aligned

	if current_wave > waves and shop_phase == false:
		shop_phase = true
		var yt = shop_ui.instantiate()
		UI_layer.add_child.call_deferred(yt)

func _start_new_wave():
	if hole_container.get_child_count() <= 0 and current_wave <= waves:
		hole_placer._place_holes()
		countdown.start()
		current_wave += 1
		print("YOU WIN!!")
