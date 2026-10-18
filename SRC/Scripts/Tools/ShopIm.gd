extends TextureRect
class_name Upgrade_shop

@export var label_name : Label
@export var label_desc : Label
@export var cost_label : Label
@export var button : Button

# This will be injected by the main script before the node enters the tree
var upgrade_data = null

func _ready() -> void:
	if upgrade_data == null:
		return # Safety check if template node is visible by mistake

	label_name.text = upgrade_data.upd.upname
	label_desc.text = upgrade_data.upd.updesc
	tooltip_text = upgrade_data.upd.uplodesc
	cost_label.text = str(upgrade_data.upd.upcost)

	button.pressed.connect(func():
		if Global.currency >= upgrade_data.upd.upcost:
			Global.currency -= upgrade_data.upd.upcost
			Global.buy.emit(upgrade_data.upd.upid)
			queue_free()
	)
