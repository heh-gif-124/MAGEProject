extends Node
@export var shop_thing : Upgrade_shop
@export var to_a: VBoxContainer
@export var to_b: VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 2:
		var y = shop_thing.duplicate()
		y.visible = true
		to_a.add_child.call_deferred(y)
	for i in 2:
		var y = shop_thing.duplicate()
		y.visible = true
		to_b.add_child.call_deferred(y)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
