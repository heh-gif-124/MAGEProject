extends Node
class_name HolePlacer
@export var hole_amount : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		if i.is_class("Marker3D"):
			print(i.global_position)
