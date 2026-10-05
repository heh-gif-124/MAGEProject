extends TextureRect
class_name Upgrade_shop
@export var label_name : Label
@export var label_desc : Label
@export var cost_label : Label
@export var button : Button
var cost : float
var upgrade : Array = [slow_down.new(),Minimap.new(),Dash.new()]
var chosen_upgrade : Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var g = upgrade.pick_random()
	label_name.text = g.upd.upname
	label_desc.text = g.upd.updesc
	button.pressed.connect(func():
		Global.currency -= cost
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
