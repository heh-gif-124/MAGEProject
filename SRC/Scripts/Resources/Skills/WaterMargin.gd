extends Node
class_name water_margin
var upd : UpgradeRes = UpgradeRes.new("Slow Down",
	"WMN",
	"Increases the time in the countdown",
	"increases the countdown time to 10.",
	200)



func _ready() -> void:
	var t : Timer = get_tree().get_first_node_in_group("Countdown")
	t.wait_time += 10
