extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Map.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit();

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn")
