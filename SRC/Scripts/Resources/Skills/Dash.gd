extends Node
class_name Dash
var upd : UpgradeRes = UpgradeRes.new("Dash", "DDH","Replaces your sprint with a dash", 450)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.minigame_initiated == true:
		Engine.time_scale = 0.2
	elif Global.minigame_initiated == false:
		Engine.time_scale = 1
