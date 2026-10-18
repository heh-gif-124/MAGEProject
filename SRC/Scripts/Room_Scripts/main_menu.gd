extends Control

@onready var warning_panel: Control = %Warning_Panel

@export var save_file_scene: String
@export var credits_scene: String

# Track pending action using StringName or Enum for efficiency
var pending_action: StringName = &""
var anim_count: int = 0

func _ready() -> void:
	warning_panel.back_pressed.connect(_on_warning_back_pressed)
	warning_panel.confirm_pressed.connect(_on_warning_confirm_pressed)
	%Fade_Trans.fade_out()
	SceneManager.load_scene_silently(credits_scene)

func _on_start_pressed() -> void:
	SceneManager.load_scene_silently(save_file_scene)
	pending_action = &"Start"
	%Intro_Player.play("intro_start_0")

func _on_settings_pressed() -> void:
	%Settings_Panel.visible = true

func _on_exit_pressed() -> void:
	warning_panel.show_warning("Exit the Game?", 1)

func _on_credit_pressed() -> void:
	pending_action = &"Credits"
	%Fade_Trans.fade_in()

func _on_fade_trans_fade_completed(_anim: StringName) -> void:
	match pending_action:
		&"Start":
			if save_file_scene:
				SceneManager.load_scene(save_file_scene)
			else:
				push_error("Save file scene is missing in main_menu.gd!")
		&"Credits":
			if credits_scene:
				SceneManager.load_scene(credits_scene)
			else:
				push_error("Credits scene is missing in main_menu.gd!")


func _on_end_anim_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("intro_start_"):
		anim_count += 1
		if anim_count >= 3:
			%Fade_Trans.fade_in()
			return
		%Intro_Player.play("intro_start_%d" % anim_count)

func _on_warning_confirm_pressed(_var_id: int) -> void:
	if _var_id != 1:
		return
	%Fade_Trans.fade_in()
	await %Fade_Trans.fade_completed
	get_tree().quit()

func _on_warning_back_pressed() -> void:
	print("The back button was pressed inside the warning popup!")
