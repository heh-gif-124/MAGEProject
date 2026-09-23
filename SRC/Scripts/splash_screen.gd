extends Control

@export_file("*.tscn") var target_scene: String = "res://Scenes/MainMenu.tscn"

@export_group("Timings")
@export var fade_in_time: float = 0.8
@export var hold_time: float = 1.2
@export var fade_out_time: float = 0.6

@onready var logo_container: Control = $Logo_Container

var _is_skipping: bool = false
var _active_tween: Tween

func _ready() -> void:
	# Hide all logo children initially
	for child in logo_container.get_children():
		if child is CanvasItem:
			child.modulate.a = 0.0
	_play_sequence()

func _unhandled_input(event: InputEvent) -> void:
	# Skip the splash sequence on any key, mouse click, or controller button
	if event.is_pressed() && !_is_skipping:
		_skip_splash()

func _play_sequence() -> void:
	for logo in logo_container.get_children():
		if not logo is CanvasItem or _is_skipping:
			continue

		_active_tween = create_tween()
		
		# Fade In -> Hold -> Fade Out
		_active_tween.tween_property(logo, "modulate:a", 1.0, fade_in_time)
		_active_tween.tween_interval(hold_time)
		_active_tween.tween_property(logo, "modulate:a", 0.0, fade_out_time)

		await _active_tween.finished

	if not _is_skipping:
		_change_to_main_menu()

func _skip_splash() -> void:
	_is_skipping = true
	if _active_tween and _active_tween.is_running():
		_active_tween.kill()
	_change_to_main_menu()

func _change_to_main_menu() -> void:
	get_tree().change_scene_to_file(target_scene)


func _on_pressed() -> void:
	if !_is_skipping:
		_skip_splash()
