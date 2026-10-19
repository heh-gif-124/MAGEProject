extends Node
class_name JumpHeight
var upd : UpgradeRes = UpgradeRes.new("JumpHeight",
	"JJH",
	"Increases your jump height",
	"Increases your jump height, allowing for more higher jumps",
	300)



func _ready() -> void:
	Global.jump_applier += 1
