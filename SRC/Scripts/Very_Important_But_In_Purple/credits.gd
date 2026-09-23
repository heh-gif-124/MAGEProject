extends Control

var pending_action: StringName = &""

@export var scroll_speed: float = 100.0  # Pixels per second
@export var fast_speed: float = 300.0    # Speed when holding 'ui_down' or Space

@onready var credits_label: RichTextLabel = $Credits_Contents

var current_speed: float

func _ready() -> void:
	current_speed = scroll_speed
	credits_label.position.y = get_viewport_rect().size.y
	
	%Fade_Trans.fade_out()

func _process(delta: float) -> void:
	# Speed up if the user holds down/space, or skip if Esc is pressed
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_accept"):
		current_speed = fast_speed
	else:
		current_speed = scroll_speed

	# Auto-scrolls the credits
	credits_label.position.y -= current_speed * delta

	# Check if the entire label has scrolled past the top of the screen
	if credits_label.position.y < -credits_label.size.y:
		_end_credits()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_end_credits()

func _end_credits() -> void:
	pending_action = &"Credits"
	%Fade_Trans.fade_in()

func _on_fade_trans_fade_completed() -> void:
		if pending_action == &"Start":
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		else:
			get_tree().quit()
