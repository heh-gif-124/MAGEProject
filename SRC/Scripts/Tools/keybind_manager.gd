extends VBoxContainer

@export var key_row_scene: PackedScene

const CONFIG_NAMES: Array[StringName] = [
	"up_input",
	"down_input",
	"left_input",
	"right_input",
	"jump",
	"interact",
	"sprint"
]

const CONFIGURABLE_ACTIONS: Array[StringName] = [
	&"walk_up",
	&"walk_down",
	&"walk_left",
	&"walk_right",
	&"jump",
	&"interact",
	&"sprint"
]

var remapping_action: StringName = &""
var remapping_row: HBoxContainer = null

func _ready() -> void:
	assert(key_row_scene != null, "Key row scene is missing in keybind_manager.gd!")
	_create_keybind_rows()

func _create_keybind_rows() -> void:
	# Clear placeholder nodes if any
	for child in get_children():
		child.queue_free()
		
	# Loop through both arrays using an index
	for i in range(CONFIG_NAMES.size()):
		var display_name = CONFIG_NAMES[i]
		var action = CONFIGURABLE_ACTIONS[i]
		
		var row = key_row_scene.instantiate()
		add_child(row)
		
		# Pass both the display name and the action to your row script
		row.setup(display_name, action)
		row.rebind_requested.connect(_on_rebind_requested.bind(row))
	_update_all_row_displays()

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
	
	for action in CONFIGURABLE_ACTIONS:
		if action == remapping_action:
			continue
			
		var existing_events = InputMap.action_get_events(action)
		for old_event in existing_events:
			# Check if this exact key/button is already bound elsewhere
			if old_event.is_match(event):
				# Clear it from the conflicting action so it doesn't have duplicate binds
				InputMap.action_erase_event(action, old_event)
	
	InputMap.action_erase_events(remapping_action)
	InputMap.action_add_event(remapping_action, event)
	
	_finish_rebind()
	get_viewport().set_input_as_handled()

func _finish_rebind() -> void:
	if remapping_row:
		remapping_row.update_key_display()
	remapping_action = &""
	remapping_row = null

# Writes current InputMap bindings into the shared ConfigFile section
func save_keybinds(config: ConfigFile) -> void:
	for action in CONFIGURABLE_ACTIONS:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			config.set_value("keybinds", String(action), events[0])

# Reads [keybinds] from the loaded ConfigFile and updates InputMap & UI
func load_keybinds(config: ConfigFile) -> void:
	for action in CONFIGURABLE_ACTIONS:
		var action_str = String(action)
		if config.has_section_key("keybinds", action_str):
			var event = config.get_value("keybinds", action_str) as InputEvent
			if event:
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)
	
	_update_all_row_displays()

# Restores project settings default keybindings
func reset_keybinds_to_default() -> void:
	InputMap.load_from_project_settings()
	_update_all_row_displays()

func _update_all_row_displays() -> void:
	for child in get_children():
		if child.has_method("update_key_display"):
			child.update_key_display()
