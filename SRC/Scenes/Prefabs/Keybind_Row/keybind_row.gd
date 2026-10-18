extends HBoxContainer

signal rebind_requested(action_name: StringName, button_node: Button)

@onready var action_label: Label = $ActionLabel
@onready var key_button: Button = $KeyButton

var action_name: StringName = &""

func setup(label: StringName, action: StringName) -> void:
	action_name = action
	# Format action name nicely (e.g., "move_forward" -> "Move Forward")
	action_label.text = label.to_pascal_case().capitalize()
	update_key_display()

func update_key_display() -> void:
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		key_button.text = events[0].as_text().replace(" (Physical)", "")
	else:
		key_button.text = "Unbound"

func _on_key_button_pressed() -> void:
	rebind_requested.emit(action_name, key_button)
