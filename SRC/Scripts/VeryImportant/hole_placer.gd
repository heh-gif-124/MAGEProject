extends Node
class_name HolePlacer
@export var hole_amount : int = 5
@export var hole : PackedScene
@export var hole_container : Node3D
var minigame_children : Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_place_holes()

func reset_holes():
	_remove_holes()
	_place_holes()

func _place_holes():
	for i in get_children():
		var t = 0
		t+=1
		var rand = randi_range(1,2)
		if rand == 2:
			if i.is_class("Marker3D"):
					print(i.global_position)
					var g = hole.instantiate()
					g.id = t
					g.global_position = i.global_position
					minigame_children.append(g)
					hole_container.add_child.call_deferred(g)
					print(g.id)
					print(minigame_children.size())

func _remove_holes():
	for i in get_parent().get_children():
		if i.is_in_group("Hole"):
			i.queue_free()
