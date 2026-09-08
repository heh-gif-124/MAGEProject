extends Control

@export var trans_duration: float = 0.5;  # Transition time in seconds

# UI Panel References
@onready var title_panel: Control = $CanvasLayer/Title_Panel;
@onready var settings_panel: Control = $CanvasLayer/Settings_Panel;

# Title Button References
@onready var start_button: Button = $CanvasLayer/Title_Panel/Container/Start;
@onready var settings_button: Button = $CanvasLayer/Title_Panel/Container/Settings;
@onready var exit_button: Button = $CanvasLayer/Title_Panel/Container/Exit;

var menu_tween: Tween
var screen_width: float = 0.0
var screen_height: float = 0.0

func _ready() -> void:
	
	# Sets the Master volume to the default 60%
	AudioServer.set_bus_volume_db(0, linear_to_db(0.6));
	
	# Sets Default window size
	DisplayServer.window_set_size(Vector2i(1280, 720));
	
	# Calculate viewport for sliding panels
	screen_width = get_viewport_rect().size.x;
	screen_height = get_viewport_rect().size.y;
	
	# Initial positions
	title_panel.position.x = 0.0;
	settings_panel.position.x = screen_width;
	
	# Wire up Title buttons
	start_button.pressed.connect(_on_start_pressed);
	settings_button.pressed.connect(_on_settings_pressed);
	exit_button.pressed.connect(_on_exit_pressed);
	
	# Auto-Connect all interactive UI elements inside Settings_Panel
	for ui in settings_panel.find_children("*", "Control"):
		if (ui is CheckBox || ui is CheckButton):
			ui.toggled.connect(_on_settings_toggle.bind(ui.name))
		elif (ui is OptionButton):
			ui.item_selected.connect(_on_settings_option.bind(ui.name))
		elif (ui is Slider):
			ui.value_changed.connect(_on_settings_slider.bind(ui.name))
		elif (ui is Button):
			ui.pressed.connect(_on_settings_button.bind(ui.name))

# Title Button Handlers
func _on_start_pressed() -> void:
	# Insert scene load or save-slot transition logic here
	
	get_tree().change_scene_to_file("res://Scenes/Map.tscn");

func _on_exit_pressed() -> void:
	get_tree().quit();

func _on_settings_pressed() -> void:
	# Slide Title off to the left, slide Settings into view from the right
	_transition_panels(-screen_width, 0.0);

# 1. Standard Push Buttons
func _on_settings_button(button_name: String) -> void:
	# .replace("_", "") allows matching "Reset_To_Default" as "resettodefault"
	var clean_name = button_name.to_lower().replace("_", "")
	match clean_name:
		"back":
			_transition_panels(0.0, screen_width);
		"apply":
			pass; # Save active settings to config file
		"resettodefault":
			_reset_settings_to_default();

# 2. Sliders
func _on_settings_slider(value: float, slider_name: String) -> void:
	var clean_name = slider_name.to_lower().replace("_", "");
	match clean_name:
		"masterslider", "mastervolume":
			var bus_idx = AudioServer.get_bus_index("Master");
			var master_label = $CanvasLayer/Settings_Panel/ScrollContainer/Container/Master_Volume/HBoxContainer/Master_Value;
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value));
			master_label.text = str(int(value * 100)) + "%";
		"sfxslider", "sfxvolume":
			var bus_idx = AudioServer.get_bus_index("SFX");
			var sfx_label = $CanvasLayer/Settings_Panel/ScrollContainer/Container/SFX_Volume/HBoxContainer/SFX_Value;
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value));
			sfx_label.text = str(int(value * 100)) + "%";
		"musicslider", "musicvolume":
			var bus_idx = AudioServer.get_bus_index("Music");
			var master_label = $CanvasLayer/Settings_Panel/ScrollContainer/Container/Music_Volume/HBoxContainer/Music_Value;
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value));
			master_label.text = str(int(value * 100)) + "%";
		"uislider", "uivolume":
			var bus_idx = AudioServer.get_bus_index("UI");
			var sfx_label = $CanvasLayer/Settings_Panel/ScrollContainer/Container/UI_Volume/HBoxContainer/UI_Value;
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value));
			sfx_label.text = str(int(value * 100)) + "%";
		"framerateslider":
			var fps_value = int(value)
			var fps_label = $CanvasLayer/Settings_Panel/ScrollContainer/Container/Frame_Rate/HBoxContainer/Frame_Rate_Value;
			if (fps_value == 0):
				Engine.max_fps = 0;
				fps_label.text = "Uncapped";
			else:
				# Clamp low values so players can't accidentally set unplayable 0-20 FPS
				fps_value = max(30, fps_value);
				Engine.max_fps = fps_value;
				fps_label.text = str(fps_value) + " FPS";

# 3. Toggles & CheckBoxes
func _on_settings_toggle(toggled_on: bool, toggle_name: String) -> void:
	var clean_name = toggle_name.to_lower().replace("_", "");
	match clean_name:
		"fullscreentoggle", "fullscreen":
			var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED;
			DisplayServer.window_set_mode(mode);
		"vsync":
			var vsync_mode = DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED;
			DisplayServer.window_set_vsync_mode(vsync_mode);
		"mastermute", "mutemaster":
			var bus_idx = AudioServer.get_bus_index("Master");
			AudioServer.set_bus_mute(bus_idx, toggled_on);
		"sfxmute", "mutesfx":
			var bus_idx = AudioServer.get_bus_index("SFX");
			AudioServer.set_bus_mute(bus_idx, toggled_on);
		"musicmute", "mutemusic":
			var bus_idx = AudioServer.get_bus_index("Music");
			AudioServer.set_bus_mute(bus_idx, toggled_on);
		"uimute", "muteui":
			var bus_idx = AudioServer.get_bus_index("UI");
			AudioServer.set_bus_mute(bus_idx, toggled_on);

# 4. Dropdowns / OptionButtons
func _on_settings_option(index: int, option_name: String) -> void:
	var clean_name = option_name.to_lower().replace("_", "");
	match clean_name:
		"resolutiondropdown", "resolution":
			match index:
				0: DisplayServer.window_set_size(Vector2i(1280, 720));
				1: DisplayServer.window_set_size(Vector2i(1920, 1080));
				2: DisplayServer.window_set_size(Vector2i(2560, 1440));

func _reset_settings_to_default():
	pass;

# Smooth Panel Slide Transition
func _transition_panels(target_title_x: float, target_settings_x: float) -> void:
	if menu_tween and menu_tween.is_running():
		menu_tween.kill();

	menu_tween = create_tween();
	menu_tween.set_parallel(true);
	menu_tween.set_trans(Tween.TRANS_CUBIC);
	menu_tween.set_ease(Tween.EASE_OUT);
	
	menu_tween.tween_property(title_panel, "position:x", target_title_x, trans_duration);
	menu_tween.tween_property(settings_panel, "position:x", target_settings_x, trans_duration);
