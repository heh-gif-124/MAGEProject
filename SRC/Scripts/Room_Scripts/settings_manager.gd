# This scrip was made By StarlightDev, credits are appreciated :3

extends Node

const SAVE_PATH: String = "user://SaveFiles/config.cfg"

@onready var warning_panel: Control = %Warning_Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	warning_panel.back_pressed.connect(_on_warning_back_pressed)
	warning_panel.confirm_pressed.connect(_on_warning_confirm_pressed)
	
	# Sets Default window size
	DisplayServer.window_set_size(Vector2i(1280, 720))
	
	# Auto-Connect all interactive UI elements inside Settings_Panel
	for ui in find_children("*", "Control", true, false):
		if ui is CheckBox || ui is CheckButton:
			ui.toggled.connect(_on_settings_toggle.bind(ui.name))
		elif ui is OptionButton:
			ui.item_selected.connect(_on_settings_option.bind(ui.name))
		elif ui is Slider:
			ui.value_changed.connect(_on_settings_slider.bind(ui.name))
		elif ui is Button:
			ui.pressed.connect(_on_settings_button.bind(ui.name))
	
	# Loads Settings
	_load_settings()

# 1. Standard Push Buttons
func _on_settings_button(button_name: String) -> void:
	# .replace("_", "") allows matching "Reset_To_Default" as "resettodefault"
	var clean_name = button_name.to_lower().replace("_", "")
	match (clean_name):
		"back":
			%Settings_Panel.hide()
		"apply":
			_save_settings()
		"resettodefault":
			warning_panel.show_warning("Reset Settings?", 0)

# 2. Sliders
func _on_settings_slider(value: float, slider_name: String) -> void:
	var clean_name = slider_name.to_lower().replace("_", "")
	match (clean_name):
		"masterslider", "mastervolume":
			var bus_idx = AudioServer.get_bus_index("Master")
			var master_label = %Master_Value
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
			master_label.text = str(int(value * 100)) + "%"
		"sfxslider", "sfxvolume":
			var bus_idx = AudioServer.get_bus_index("SFX")
			var sfx_label = %SFX_Value
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
			sfx_label.text = str(int(value * 100)) + "%"
		"musicslider", "musicvolume":
			var bus_idx = AudioServer.get_bus_index("Music")
			var music_label = %Music_Value
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
			music_label.text = str(int(value * 100)) + "%"
		"uislider", "uivolume":
			var bus_idx = AudioServer.get_bus_index("UI")
			var ui_label = %UI_Value
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
			ui_label.text = str(int(value * 100)) + "%"
		"framerateslider":
			var fps_value = int(value)
			var fps_label = %Frame_Rate_Value
			if fps_value == 0:
				Engine.max_fps = 0
				fps_label.text = "Uncapped"
			else:
				# Clamp low values so players can't accidentally set unplayable 0-20 FPS
				fps_value = max(30, fps_value)
				Engine.max_fps = fps_value
				fps_label.text = str(fps_value) + " FPS"

# 3. Toggles & CheckBoxes
func _on_settings_toggle(toggled_on: bool, toggle_name: String) -> void:
	var clean_name = toggle_name.to_lower().replace("_", "")
	match (clean_name):
		"vsync":
			var vsync_mode = DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED
			DisplayServer.window_set_vsync_mode(vsync_mode)
		"zoomtoggle":
			# Safely update the live map IF it currently exists in the current scene tree
			var active_map = get_tree().root.find_child("Game_Map", true, false)
			if active_map and active_map is TextureRect:
				active_map.zoom_to_cursor = toggled_on
				
			# Safely update the ConfigFile
			var config = ConfigFile.new()
			config.load(SAVE_PATH) # Load existing file
			config.set_value("game", "cursor_zoom", toggled_on)
			config.save(SAVE_PATH)
		"mastermute", "mutemaster":
			var bus_idx = AudioServer.get_bus_index("Master")
			AudioServer.set_bus_mute(bus_idx, toggled_on)
		"sfxmute", "mutesfx":
			var bus_idx = AudioServer.get_bus_index("SFX")
			AudioServer.set_bus_mute(bus_idx, toggled_on)
		"musicmute", "mutemusic":
			var bus_idx = AudioServer.get_bus_index("Music")
			AudioServer.set_bus_mute(bus_idx, toggled_on)
		"uimute", "muteui":
			var bus_idx = AudioServer.get_bus_index("UI")
			AudioServer.set_bus_mute(bus_idx, toggled_on)

# 4. Dropdowns / OptionButtons
func _on_settings_option(index: int, option_name: String) -> void:
	var clean_name = option_name.to_lower().replace("_", "")
	match (clean_name):
		"resolutiondropdown", "resolution":
			match (index):
				0: DisplayServer.window_set_size(Vector2i(1280, 720))
				1: DisplayServer.window_set_size(Vector2i(1920, 1080))
				2: DisplayServer.window_set_size(Vector2i(2560, 1440))
		"displaymode", "displaymodedropdown":
			var mode: DisplayServer.WindowMode
			match (index):
				0: # Windowed
					mode = DisplayServer.WINDOW_MODE_WINDOWED
					DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
					print("Is now window")
				1: # Borderless Window
					mode = DisplayServer.WINDOW_MODE_WINDOWED
					DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
					print("Is now window but slim")
				2: # Borderless Fullscreen
					mode = DisplayServer.WINDOW_MODE_FULLSCREEN
					print("Is now fullscreen")
				3: # Exclusive Fullscreen
					mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
					DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
					print("Is now fullscreen but fat")
			DisplayServer.window_set_mode(mode)

func _save_settings() -> void:
	var dir_path = SAVE_PATH.get_base_dir()
	if !DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	var config = ConfigFile.new()
	
	# Audio Settings
	if has_node("%Master_Slider"): config.set_value("audio", "master_volume", %Master_Slider.value)
	if has_node("%Master_Mute"): config.set_value("audio", "master_mute", %Master_Mute.button_pressed)
	if has_node("%SFX_Slider"): config.set_value("audio", "sfx_volume", %SFX_Slider.value)
	if has_node("%SFX_Mute"): config.set_value("audio", "sfx_mute", %SFX_Mute.button_pressed)
	if has_node("%Music_Slider"): config.set_value("audio", "music_volume", %Music_Slider.value)
	if has_node("%Music_Mute"): config.set_value("audio", "music_mute", %Music_Mute.button_pressed)
	if has_node("%UI_Slider"): config.set_value("audio", "ui_volume", %UI_Slider.value)
	if has_node("%UI_Mute"): config.set_value("audio", "ui_mute", %UI_Mute.button_pressed)
	
	# Video Settings
	if has_node("%Display_Mode_Dropdown"): config.set_value("video", "display_mode", %Display_Mode_Dropdown.selected)
	if has_node("%VSync"): config.set_value("video", "vsync", %VSync.button_pressed)
	if has_node("%Frame_Rate_Slider"): config.set_value("video", "fps_limit", %Frame_Rate_Slider.value)
	if has_node("%Resolution_Dropdown"): config.set_value("video", "resolution", %Resolution_Dropdown.selected)
	
	if has_node("%Zoom_Toggle"): config.set_value("game", "cursor_zoom", %Zoom_Toggle.button_pressed)
	
	# Keybind Settings
	if has_node("%Keybind_Manager"):
		%Keybind_Manager.save_keybinds(config)
	
	config.save(SAVE_PATH)

# Read file from disk and update UI controls (which triggers their signals to apply settings)
func _load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)
	
	# If the file doesn't exist yet, do nothing (uses default inspector values)
	if error != OK:
		return
		
	# Apply Audio values to UI controls
	if has_node("%Master_Slider"):
		%Master_Slider.value = config.get_value("audio", "master_volume", 1.0)
	if has_node("%Master_Mute"):
		%Master_Mute.button_pressed = config.get_value("audio", "master_mute", false)
	if has_node("%SFX_Slider"):
		%SFX_Slider.value = config.get_value("audio", "sfx_volume", 1.0)
	if has_node("%SFX_Mute"):
		%SFX_Mute.button_pressed = config.get_value("audio", "sfx_mute", false)
	if has_node("%Music_Slider"):
		%Music_Slider.value = config.get_value("audio", "music_volume", 1.0)
	if has_node("%Music_Mute"):
		%Music_Mute.button_pressed = config.get_value("audio", "music_mute", false)
	if has_node("%UI_Slider"):
		%UI_Slider.value = config.get_value("audio", "ui_volume", 1.0)
	if has_node("%UI_Mute"):
		%UI_Mute.button_pressed = config.get_value("audio", "ui_mute", false)
		
	# Apply Video values to UI controls
	if has_node("%Display_Mode_Dropdown"):
		%Display_Mode_Dropdown.selected = config.get_value("video", "display_mode", 0)
		# Manually trigger option signal since setting 'selected' via script doesn't auto-emit item_selected
		_on_settings_option(%Display_Mode_Dropdown.selected, "displaymodedropdown")
	if has_node("%VSync"):
		%VSync.button_pressed = config.get_value("video", "vsync", false)
	if has_node("%Frame_Rate_Slider"):
		%Frame_Rate_Slider.value = config.get_value("video", "fps_limit", 60.0)
	if has_node("%Resolution_Dropdown"):
		%Resolution_Dropdown.selected = config.get_value("video", "resolution", 0)
		# Manually trigger option signal since setting 'selected' via script doesn't auto-emit item_selected
		_on_settings_option(%Resolution_Dropdown.selected, "resolution")
	
	if has_node("%Zoom_Toggle"):
		%Zoom_Toggle.button_pressed = config.get_value("game", "cursor_zoom", true)
	
	# Apply Keybind values to UI controls
	if has_node("%Keybind_Manager"):
		%Keybind_Manager.load_keybinds(config)

func _reset_settings_to_default() -> void:
	var config = ConfigFile.new()
	
	# 1. Populate the config with clean default values
	# Audio Defaults
	config.set_value("audio", "master_volume", 1.0)
	config.set_value("audio", "master_mute", false)
	config.set_value("audio", "sfx_volume", 1.0)
	config.set_value("audio", "sfx_mute", false)
	config.set_value("audio", "music_volume", 1.0)
	config.set_value("audio", "music_mute", false)
	config.set_value("audio", "ui_volume", 1.0)
	config.set_value("audio", "ui_mute", false)
	
	# Video Defaults
	config.set_value("video", "display_mode", 0)
	config.set_value("video", "vsync", false)
	config.set_value("video", "fps_limit", 60.0)
	config.set_value("video", "resolution", 0)
	
	# Game Preference Defaults
	config.set_value("game", "cursor_zoom", true)
	
	# 2. Reset Keybinds back to defaults in the InputMap
	if has_node("%Keybind_Manager"):
		%Keybind_Manager.reset_keybinds_to_default()
		%Keybind_Manager.save_keybinds(config)
	
	# 3. Ensure directory exists and save the fresh default config
	var dir_path = SAVE_PATH.get_base_dir()
	if !DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	config.save(SAVE_PATH)
	
	# 4. Instantly load the config, which forces every UI control 
	# to update its visual state and fire its signal!
	_load_settings()
	
	print("Settings successfully reset to defaults and updated visually!")

func _on_warning_confirm_pressed(_var_id: int) -> void:
	if _var_id == 0:
		print("Settings Reseted")
		_reset_settings_to_default()

func _on_warning_back_pressed() -> void:
	print("The back button was pressed inside the warning popup!")
