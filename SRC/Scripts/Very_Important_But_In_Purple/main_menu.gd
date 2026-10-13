extends Control

# Track pending action using StringName or Enum for efficiency
var pending_action: StringName = &""
var anim_count: int = -1

func _ready() -> void:
	_on_end_anim_finished("intro_start_")

func _on_start_pressed() -> void:
	pending_action = &"Start"
	%Fade_Trans.fade_in()

func _on_settings_pressed() -> void:
	%Settings_Panel.visible = true

func _on_exit_pressed() -> void:
	%Fade_Trans.fade_in()
	await %Fade_Trans.fade_completed
	get_tree().quit()

func _on_credit_pressed() -> void:
	pending_action = &"Credits"
	%Fade_Trans.fade_in()

func _on_fade_trans_fade_completed() -> void:
	match pending_action:
		&"Start":
			get_tree().change_scene_to_file("res://Scenes/SaveFiles.tscn")
		&"Credits":
			get_tree().change_scene_to_file("res://Scenes/Credits.tscn")


func _on_end_anim_finished(anim_name: StringName) -> void:
	if anim_name.contains("intro_start_"):
		anim_count = anim_count + 1
		if anim_count >= 3:
			return
		%Intro_Player.play("intro_start_%d" % anim_count)
