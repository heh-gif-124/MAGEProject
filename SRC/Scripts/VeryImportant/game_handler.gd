extends Node
class_name GameHandler
@export var hole_placer : HolePlacer
@export var countdown : Timer
@export var countdown_label : Label
@export var minigames_list : Array[Control]
var in_minigame : bool = false
var minigames_needed : int
var won_already : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minigames_needed = hole_placer.minigame_children.size()
	Global.minigame.connect(func():
		var k : Control = minigames_list.pick_random()
		k.visible = true
		Global.minigame_initiated = true
	)

func _process(delta: float) -> void:
	countdown_label.text = str(int(ceil(countdown.time_left)))
	if Global.minigames_completed >= minigames_needed:
		won_already = true
		print("win")


func _countdown():
	if won_already == false:
		await countdown.timeout
		print("YOU LOSE")
