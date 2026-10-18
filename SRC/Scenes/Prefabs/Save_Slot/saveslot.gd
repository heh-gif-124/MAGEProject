extends Node

@export var slot: int = 0

@onready var warning_panel: Control = %Warning_Panel

# Preloading textures is generally faster if paths are static
const INIT_NORMAL = preload("res://SRC/Sprites/Irrelevant/ja_rage.jpg")
const INIT_EXIST = preload("res://SRC/Sprites/Irrelevant/ja_aura.jpg")

func _ready() -> void:
	warning_panel.back_pressed.connect(_on_warning_back_pressed)
	warning_panel.confirm_pressed.connect(_on_warning_confirm_pressed)
	
	_update_slot_visuals()

func _update_slot_visuals() -> void:
	# Change the normal state texture
	if SaveManager.has_save_file(slot):
		$Save_Button.texture_normal = INIT_EXIST
		$Delete.disabled = false
	else:
		$Save_Button.texture_normal = INIT_NORMAL
		$Delete.disabled = true

func _on_save_button_pressed() -> void:
	%Fade_Trans.fade_in()
	if !SaveManager.has_save_file(slot):
		# Creating a new save from an empty slot
		SaveManager.create_and_save(slot)
		get_tree().change_scene_to_file("res://Scenes/I_Cant.tscn") # use intro scene
	else:
		SaveManager.load_game(slot)
		get_tree().change_scene_to_file("res://Scenes/Map.tscn")


func _on_delete_pressed() -> void:
	warning_panel.show_warning("Permanently delete save file?", slot)

func _on_warning_confirm_pressed(confirmed_slot: int) -> void:
	if confirmed_slot != slot:
		return
	
	print("Deleting save file for slot: ", slot)
	SaveManager.delete_save_slot(slot)
	_update_slot_visuals()

func _on_warning_back_pressed() -> void:
	print("The back button was pressed inside the warning popup!")
