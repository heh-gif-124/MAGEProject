extends Control

# Track pending action using StringName or Enum for efficiency
var pending_action: StringName = &""

func _on_start_pressed() -> void:
	pending_action = &"Start"
	%Fade_Trans.fade_in()

func _on_settings_pressed() -> void:
	pending_action = &"Settings"
	%Fade_Trans.fade_in()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_fade_trans_fade_completed() -> void:
	match pending_action:
		&"Start":
			get_tree().change_scene_to_file("res://Scenes/Map.tscn")
		&"Settings":
			get_tree().change_scene_to_file("res://Scenes/Settings.tscn")
