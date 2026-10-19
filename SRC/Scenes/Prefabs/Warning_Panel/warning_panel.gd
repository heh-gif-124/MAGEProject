extends Control

@onready var warning_label: Label = $Label

var target_var: int = -1

signal back_pressed
signal confirm_pressed(var_id: int)

func show_warning(message: String, var_id: int = -1) -> void:
	warning_label.text = message
	target_var = var_id
	show()

func _on_back_pressed() -> void:
	back_pressed.emit(target_var)
	hide()

func _on_confirm_pressed() -> void:
	confirm_pressed.emit(target_var)
	hide()
