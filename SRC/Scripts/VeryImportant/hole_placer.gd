extends Node
class_name HolePlacer
@export var hole_amount : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in hole_amount:
		print(i)
