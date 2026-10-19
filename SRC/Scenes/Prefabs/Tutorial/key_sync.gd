extends Label

const CONTROLS_TO_DISPLAY: Array[StringName] = [
	&"walk_up",
	&"walk_left",
	&"walk_down",
	&"walk_right",
	&"jump",
	&"sprint"
]

func update_hud_key_hints() -> void:
	var key_strings: Array[String] = []
	
	# Gather the formatted key text for each action
	for action in CONTROLS_TO_DISPLAY:
		key_strings.append(get_action_key_text(action))
	
	# Combine them all into a single multi-line string using newlines (\n)
	text = "\n".join(key_strings)

func get_action_key_text(action_name: StringName) -> String:
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		var key_text = events[0].as_text().replace(" - Physical", "").to_upper()
		return "[" + key_text + "]"
	return "[UNBOUND]"
