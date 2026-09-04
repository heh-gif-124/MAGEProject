extends Node
class_name GameHandler

@export var hole_placer : HolePlacer
@export var countdown : Timer
@export var countdown_label : Label
@export var minigames_list : Array[Control]
@export var next_level : PackedScene
@export var waves : int = 3

var in_minigame : bool = false
var minigames_needed : int
var won_already : bool = false
var current_wave : int = 1

func _ready() -> void:
	minigames_needed = hole_placer.minigame_children.size()

	Global.minigame.connect(func():
		var k : Control = minigames_list.pick_random()
		if k.has_method("_reset_stuff"):
			k._reset_stuff()
		Global.minigame_initiated = true
	)

func _process(_delta: float) -> void:
	print(Global.minigames_completed)
	if is_instance_valid(countdown) and countdown.time_left > 0:
		countdown_label.text = str(int(ceil(countdown.time_left)))

	if not won_already and Global.minigames_completed >= minigames_needed:
		won_already = true
		_handle_wave_completion()

func _handle_wave_completion() -> void:
	Global.minigames_completed = 0
	print("Wave ", current_wave, " cleared!")

	await get_tree().create_timer(2.0, true, true, true).timeout

	if current_wave < waves:
		_start_next_wave()
	else:
		_handle_game_win()

func _start_next_wave() -> void:
	current_wave += 1
	Global.minigames_completed = 0
	won_already = false

	# Reset hole locations if HolePlacer has a reset method
	if hole_placer and hole_placer.has_method("_place_holes"):
		hole_placer.reset_holes()
	# Restart wave countdown
	if countdown:
		countdown.start()
	print("Starting Wave ", current_wave)

func _handle_game_win() -> void:
	set_process(false)
	print("ALL WAVES CLEARED - YOU WIN!")
	if next_level:
		get_tree().change_scene_to_packed(next_level)

func _countdown():
	if not won_already:
		await countdown.timeout
		print("YOU LOSE")
