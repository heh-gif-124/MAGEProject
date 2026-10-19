extends Control
@export var yes_button : Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var minigameholder = get_tree().get_first_node_in_group("MinigameHolder")
	if minigameholder:
		minigameholder.queue_free()
	yes_button.pressed.connect(func():
		total_soft_reset()
	)


func total_soft_reset():
	# 1. Reset your Autoload data (e.g., ScoreManager, GameManager)
	Global.currency = 0
	Global.minigame_initiated = false
	# 2. Reload the root or main menu scene
	get_tree().reload_current_scene()
