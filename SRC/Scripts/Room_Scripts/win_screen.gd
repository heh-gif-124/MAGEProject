extends Control
@export var yes_button : Button
@export var no_button : Button
@export var main_menu : String
@export var level_1 : String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var minigameholder = get_tree().get_first_node_in_group("MinigameHolder")
	if minigameholder:
		minigameholder.queue_free()
	yes_button.pressed.connect(func():
		total_soft_reset()
	)
	no_button.pressed.connect(func():
		SceneManager.load_scene(main_menu)
	)


func total_soft_reset():
	# 1. Reset your Autoload data (e.g., ScoreManager, GameManager)
	Global.currency = 0
	Global.minigame_initiated = false
	# 2. Reload the root or main menu scene
	SceneManager.load_scene(level_1)
