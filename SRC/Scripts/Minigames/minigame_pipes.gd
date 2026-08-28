extends Control

var current_dot_index : int = 1
var total_dots : int = 0
var started : bool = false
var won : bool = false

@export var line_node : Line2D
@export var dots_container : Node2D
@export var winlabel : Label
@export var status_bar : ProgressBar

var stylebox : StyleBoxFlat

func _ready() -> void:
	# Duplicate stylebox so color changes don't affect other progress bars
	if status_bar and status_bar.has_theme_stylebox_override("fill"):
		stylebox = status_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
		status_bar.add_theme_stylebox_override("fill", stylebox)

	_setup_dots()

	Global.minigame.connect(func():
		if stylebox:
			stylebox.bg_color = Color.GRAY

		current_dot_index = 1
		line_node.clear_points()
		winlabel.visible = false
		started = false
		won = false
		visible = true

		await get_tree().create_timer(0.5, true, false, true).timeout
		started = true
	)

func _setup_dots() -> void:
	var dot_nodes = dots_container.get_children()
	total_dots = dot_nodes.size()

	for i in range(dot_nodes.size()):
		var dot = dot_nodes[i]
		var dot_number = i + 1
		if dot.has_signal("input_event"):
			dot.input_event.connect(_on_dot_input_event.bind(dot_number, dot))

func _physics_process(_delta: float) -> void:
	if not Global.minigame_initiated or not started or won:
		return

	# Live Line Tracking (Follows mouse cursor from last dot)
	_update_mouse_line()

	# Check Win Condition
	if current_dot_index > total_dots:
		won = true
		Global.minigames_completed += 1
		winlabel.visible = true

		if stylebox:
			stylebox.bg_color = Color.GREEN

		# Close the final shape loop
		if line_node.get_point_count() > 1:
			line_node.add_point(line_node.get_point_position(0))

		await get_tree().create_timer(1.5, true, false, true).timeout
		Global.minigame_initiated = false
		visible = false
		return

	# Active Gameplay Color
	if stylebox and stylebox.bg_color != Color.RED:
		stylebox.bg_color = Color.RED

func _process(_delta: float) -> void:
	if status_bar and total_dots > 0:
		status_bar.value = (float(current_dot_index - 1) / float(total_dots)) * 100.0

func _on_dot_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, dot_number: int, dot_node: Node2D) -> void:
	if not Global.minigame_initiated or not started or won:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dot_number == current_dot_index:
			_connect_dot(dot_node.global_position)
			current_dot_index += 1

func _connect_dot(point_position: Vector2) -> void:
	var local_pos = line_node.to_local(point_position)
	if line_node.get_point_count() >= current_dot_index:
		line_node.set_point_position(current_dot_index - 1, local_pos)
	else:
		line_node.add_point(local_pos)

func _update_mouse_line() -> void:
	if current_dot_index <= 1:
		return

	var mouse_local_pos = line_node.to_local(get_global_mouse_position())
	if line_node.get_point_count() == current_dot_index:
		line_node.set_point_position(current_dot_index - 1, mouse_local_pos)
	else:
		line_node.add_point(mouse_local_pos)
