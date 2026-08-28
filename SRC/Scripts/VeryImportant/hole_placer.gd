extends Node
class_name HolePlacer
@export var hole_amount : int = 5
@export var hole : PackedScene
var minigame_children : Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		var rand = randi_range(1,2)
		if rand == 2:
			if i.is_class("Marker3D"):
					print(i.global_position)
					var g = hole.instantiate()
					g.global_position = i.global_position
					minigame_children.append(g)
					get_parent().add_child.call_deferred(g)
					print(minigame_children.size())
			
