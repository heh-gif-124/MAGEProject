extends Node
class_name Dash
var upd : UpgradeRes = UpgradeRes.new("Dash",
	"DDH",
	"Replaces your sprint with a dash",
	"Replaces your sprint with a dash,\n allowing you traverse the area much more easier",
	450)



func _ready() -> void:
	Global.dashing_unlocked = true
