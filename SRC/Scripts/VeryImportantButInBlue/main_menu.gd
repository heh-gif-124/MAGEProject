extends Control

@export var trans_duration: float = 0.5;  # Transition time in seconds

# UI References
@onready var title_panel: Control = $CanvasLayer/Title_Panel/VBoxContainer;
@onready var settings_panel: Control = $CanvasLayer/Settings_Panel/VBoxContainer;

@onready var start_button: Button = $CanvasLayer/Title_Panel/VBoxContainer/Start;
@onready var settings_button: Button = $CanvasLayer/Title_Panel/VBoxContainer/Settings;
@onready var exit_button: Button = $CanvasLayer/Title_Panel/VBoxContainer/Exit;

var menu_tween: Tween
var screen_width: float = 0.0
var screen_height: float = 0.0

func _ready() -> void:
	# Calculate viewport for sliding panels
	screen_width = get_viewport_rect().size.x;
	screen_height = get_viewport_rect().size.y;
	
	# Initial positions: Title in center, Settings tucked off-screen to the right
	title_panel.position.x = 0.0;
	settings_panel.position.x = screen_width;
	
	# Wire up button signals
	start_button.pressed.connect(_on_start_pressed);
	settings_button.pressed.connect(_on_settings_pressed);
	exit_button.pressed.connect(_on_exit_pressed);
	
	# Auto-Connect input events inside settings panel
	for ui in settings_panel.find_children("*", "Control"):
		if ui is CheckBox || ui is CheckButton:
			ui.toggled.connect(_on_settings_toggle.bind(ui.name))
		elif ui is OptionButton:
			ui.item_selected.connect(_on_settings_option.bind(ui.name))
		elif ui is Slider: # Catches HSlider and VSlider
			ui.value_changed.connect(_on_settings_slider.bind(ui.name))
		elif ui is Button: # Standard push buttons (e.g., Back, Reset)
			ui.pressed.connect(_on_settings_button.bind(ui.name))

# Button Handlers
func _on_start_pressed() -> void:
	# Slide Title off to the ???, slide Start Panel into view from the ???
	_transition_panels(-screen_height, 0.0);

func _on_exit_pressed() -> void:
	get_tree().quit();

func _on_settings_pressed() -> void:
	# Slide Title off to the left, slide Settings into view from the right
	_transition_panels(-screen_width, 0.0);

# 1. Standard Buttons (Back, Apply, Reset)
func _on_settings_button(button_name: String) -> void:
	match button_name.to_lower():
		"back", "backbutton":
			_transition_panels(0.0, screen_width);
		"resetdefaults":
			_reset_settings_to_default();

# 2. Sliders (Volume, Sensitivity, Brightness)
func _on_settings_slider(value: float, slider_name: String) -> void:
	match slider_name.to_lower():
		"mastervolume", "masterslider":
			# Convert 0.0-1.0 slider value to AudioServer decibels
			var bus_idx = AudioServer.get_bus_index("Master")
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value));
		"sfxvolume", "sfxslider":
			var bus_idx = AudioServer.get_bus_index("SFX")
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value));

# 3. CheckBoxes & CheckButtons (VSync, Fullscreen, Mute)
func _on_settings_toggle(toggled_on: bool, toggle_name: String) -> void:
	match toggle_name.to_lower():
		"fullscreen", "fullscreentoggle":
			var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
			DisplayServer.window_set_mode(mode)
		"vsync", "vsynctoggle":
			var vsync_mode = DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED
			DisplayServer.window_set_vsync_mode(vsync_mode)

# 4. OptionButtons / Dropdowns (Resolution, Graphics Quality)
func _on_settings_option(index: int, option_name: String) -> void:
	match option_name.to_lower():
		"resolution", "resolutiondropdown":
			match index:
				0: DisplayServer.window_set_size(Vector2i(1280, 720))
				1: DisplayServer.window_set_size(Vector2i(1920, 1080))
				2: DisplayServer.window_set_size(Vector2i(2560, 1440))

func _reset_settings_to_default():
	return;

# Smooth Panel Slide Transition
func _transition_panels(target_title_x: float, target_settings_x: float) -> void:
	if menu_tween and menu_tween.is_running():
		menu_tween.kill();

	menu_tween = create_tween();
	menu_tween.set_parallel(true); # Animate both panels simultaneously
	menu_tween.set_trans(Tween.TRANS_CUBIC);
	menu_tween.set_ease(Tween.EASE_OUT);
	
	menu_tween.tween_property(title_panel, "position:x", target_title_x, trans_duration);
	menu_tween.tween_property(settings_panel, "position:x", target_settings_x, trans_duration);
