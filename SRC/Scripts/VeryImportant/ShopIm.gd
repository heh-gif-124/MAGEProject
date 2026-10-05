extends TextureRect
class_name Upgrade_shop
@export var label_name : Label
@export var label_desc : Label
@export var cost_label : Label
@export var button : Button

var cost : float
var upgrade
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(func():
		Global.currency -= cost
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
