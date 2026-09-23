extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Fade_Trans.fade_out()

func _on_check_room_pressed() -> void:
	%Fade_Trans.fade_in()
	get_tree().quit()
