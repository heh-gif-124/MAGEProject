extends Node
class_name DoubleJump
var upd : UpgradeRes = UpgradeRes.new("Airjump",
	"DDJ",
	"Gives you an extra air jump",
	"An extra air jump is given to you.",
	450)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.unlocked_double_jump = true
