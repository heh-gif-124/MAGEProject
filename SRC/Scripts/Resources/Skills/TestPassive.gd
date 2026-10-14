extends Node
class_name slow_down
var upd : UpgradeRes = UpgradeRes.new("Slow Down", "SSL","Slows down time when in a Minigame","Slows down the timer when your in a minigame,\n giving you more time to spare.", 200)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.minigame_initiated == true:
		Engine.time_scale = 0.2
	elif Global.minigame_initiated == false:
		Engine.time_scale = 1
