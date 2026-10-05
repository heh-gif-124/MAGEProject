extends Area3D
var player_inside : bool = false
@export var label : Label3D
@export var minigames : Array[PackedScene]
var ui_area : CanvasLayer
var id : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_area = get_tree().get_first_node_in_group("UILayer")
	body_entered.connect(func(body):
		if body.is_in_group("Player"):
			player_inside = true
			label.visible = true
	)
	body_exited.connect(func(body):
		if body.is_in_group("Player"):
			player_inside = false
			label.visible = false

	)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_inside == true and Global.minigame_initiated == false:
		var t = minigames.pick_random()
		var minigame_chosen = t.instantiate()
		ui_area.add_child.call_deferred(minigame_chosen)
		Global.minigame.emit.call_deferred(self)
		Global.minigame_initiated = true
		print("works")
