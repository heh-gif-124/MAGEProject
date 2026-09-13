extends VBoxContainer

@export var key_row_scene: PackedScene = preload("res://SRC/Scenes/Nodes/Keybind_Row/keybind_row.tscn")

const CONFIGURABLE_ACTIONS: Array[StringName] = [
	&"move_forward",
	&"move_backward",
	&"move_left",
	&"move_right",
	&"jump"
]

var remapping_action: StringName = &""
var remapping_row: HBoxContainer = null

func _ready() -> void:
	_create_keybind_rows()

func _create_keybind_rows() -> void:
	# Clear placeholder nodes if any
	for child in get_children():
		child.queue_free()
		
	for action in CONFIGURABLE_ACTIONS:
		var row = key_row_scene.instantiate()
		add_child(row)
		row.setup(action)
		row.rebind_requested.connect(_on_rebind_requested.bind(row))

func _on_rebind_requested(action_name: StringName, button_node: Button, row_node: HBoxContainer) -> void:
	remapping_action = action_name
	remapping_row = row_node
	button_node.text = "Press any key..."

func _input(event: InputEvent) -> void:
	if remapping_action == &"":
		return
		
	if event is InputEventMouseMotion || !event.is_pressed():
		return
		
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		return

	if event.is_action_pressed("ui_cancel"):
		_finish_rebind()
		get_viewport().set_input_as_handled()
		return

	InputMap.action_erase_events(remapping_action)
	InputMap.action_add_event(remapping_action, event)
	
	_finish_rebind()
	get_viewport().set_input_as_handled()

func _finish_rebind() -> void:
	if remapping_row:
		remapping_row.update_key_display()
	remapping_action = &""
	remapping_row = null
