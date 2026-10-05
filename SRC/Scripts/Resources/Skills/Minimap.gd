extends Node
class_name Minimap
var upd : UpgradeRes = UpgradeRes.new("Minimap", "MMI","Shows a minimap of the level", 500)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.minigame_initiated == true:
		Engine.time_scale = 0.2
	elif Global.minigame_initiated == false:
		Engine.time_scale = 1
