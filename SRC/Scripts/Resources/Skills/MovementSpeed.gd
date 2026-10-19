extends Node
class_name MovementSpeed
var upd : UpgradeRes = UpgradeRes.new("MovementSpeed",
	"MMS",
	"Increases your movement speed",
	"Increases your movement speed, allowing you to move much faster.",
	200)



func _ready() -> void:
	Global.speed_applier += 1
