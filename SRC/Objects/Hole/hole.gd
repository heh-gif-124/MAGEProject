extends Area3D
var player_inside : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(func(body):	
		if body.is_in_group("Player"):
			player_inside = true
			
	)
	body_exited.connect(func(body):
		if body.is_in_group("Player"):
			player_inside = false
		
	)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_inside == true and Global.minigame_initiated == false:
		Global.minigame.emit()
		print("works")