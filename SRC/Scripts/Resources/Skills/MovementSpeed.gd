extends Node
class_name MovementSpeed
var upd : UpgradeRes = UpgradeRes.new("Movement Speed",
	"MMS",
	"Increases the time in the countdown",
	"increases the countdown time to 10.",
	300)



func _ready() -> void:
	var t : Timer = get_tree().get_first_node_in_group("Countdown")
	t.wait_time += 10
