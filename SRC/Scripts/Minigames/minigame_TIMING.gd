extends Control

var threshold : float = 0.0
var started : bool = false
var won : bool = false
var current_number = 0

@export var bar : ProgressBar
@export var winlabel : Label
@export var numlabel : Label
@export var numtimer : Timer
@export var time : float

var stylebox : StyleBoxFlat
var hydrant : Area3D
var active_tween : Tween
var base_position : Vector2

func _ready() -> void:
	stylebox = bar.get_theme_stylebox("fill") as StyleBoxFlat

	# Center control pivot for clean scaling intros/outros and punches
	pivot_offset = size / 2.0
	base_position = position

	# Ensure labels have centered pivots for clean scaling/punch effects
	if numlabel:
		numlabel.pivot_offset = numlabel.size / 2.0
	if winlabel:
		winlabel.pivot_offset = winlabel.size / 2.0

	numtimer.timeout.connect(func():
		if current_number >= 5:
			current_number = 0
		else:
			current_number += 1

		# Optional tiny pulse on every number tick to keep it alive
		_pulse_label(numlabel, Vector2(1.1, 1.1), 0.08, Color.WHITE)
	)

	Global.minigame.connect(func(hole):
		_reset_stuff()
		hydrant = hole
	)

func _process(_delta: float) -> void:
	if not Global.minigame_initiated or not started or won:
		return

	numlabel.text = str(current_number)

	# Input handling with juice punch on the whole UI element
	if Input.is_action_just_pressed("interact"):
		_punch_effect()
		if current_number == 5:
			# --- CORRECT HIT ---
			threshold = min(threshold + 33.3, 100.0)
			current_number = 0
			numtimer.wait_time = max(0.1, numtimer.wait_time - 0.3)
			_tween_bar(threshold)
			_pulse_label(numlabel, Vector2(1.4, 1.4), 0.15, Color.GREEN)
		else:
			# --- WRONG HIT ---
			threshold = max(threshold - 33.3, 0.0)
			current_number = 0
			numtimer.wait_time += 0.3
			_tween_bar(threshold)
			_shake_and_flash_label()

	# Win Condition
	if threshold >= 99.0:
		won = true
		Global.minigames_completed += 1
		winlabel.visible = true
		stylebox.bg_color = Color.GREEN

		# Juicy Win Pop Animation
		_play_win_animation()

		await get_tree().create_timer(1.5, true, false, true).timeout
		Global.minigame_initiated = false
		Global.minigame_finished.emit.call_deferred()
		Global.currency += 100
		print("Money: " + str(Global.currency))

		if is_instance_valid(hydrant):
			hydrant.queue_free()

		# Smooth scale-out outro before freeing
		await _play_outro()
		queue_free()
		return

	# Loss Condition
	if threshold < 0.0 and started:
		Global.minigame_initiated = false
		await _play_outro()
		queue_free()
		return

func _reset_stuff() -> void:
	threshold = 0
	current_number = 0
	winlabel.visible = false
	winlabel.scale = Vector2(0.2, 0.2)
	winlabel.modulate.a = 0.0

	started = false
	won = false
	visible = true
	bar.value = 0
	stylebox.bg_color = Color.RED

	# --- SCALE-IN INTRO ANIMATION ---
	scale = Vector2.ZERO
	var intro_tween = create_tween()
	intro_tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Wait for intro/initial setup delay
	await get_tree().create_timer(0.5, true, false, true).timeout

	numtimer.wait_time = time
	numtimer.start()
	started = true

# --- JUICE HELPER FUNCTIONS ---

func _punch_effect() -> void:
	# Quick scale punch on the entire UI control when interacting
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.06, 1.06), 0.04).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.08).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)

func _tween_bar(target_val: float) -> void:
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(bar, "value", target_val, 0.2)

func _pulse_label(target_label: Label, target_scale: Vector2, duration: float, tint: Color) -> void:
	if not target_label: return
	target_label.modulate = tint
	var tw = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tw.tween_property(target_label, "scale", target_scale, duration)
	tw.chain().tween_property(target_label, "scale", Vector2.ONE, duration)

	var color_tw = create_tween()
	color_tw.tween_property(target_label, "modulate", Color.WHITE, duration * 2)

func _shake_and_flash_label() -> void:
	if not numlabel: return
	numlabel.modulate = Color.RED
	var original_pos = numlabel.position

	# Shake effect
	var tw = create_tween()
	tw.tween_property(numlabel, "position", original_pos + Vector2(6, 0), 0.04)
	tw.tween_property(numlabel, "position", original_pos + Vector2(-6, 0), 0.04)
	tw.tween_property(numlabel, "position", original_pos + Vector2(4, 0), 0.04)
	tw.tween_property(numlabel, "position", original_pos, 0.04)

	var color_tw = create_tween()
	color_tw.tween_property(numlabel, "modulate", Color.WHITE, 0.3)

func _play_win_animation() -> void:
	winlabel.modulate.a = 1.0
	var tw = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(winlabel, "scale", Vector2(1.2, 1.2), 0.3)

	var color_tw = create_tween()
	color_tw.tween_property(winlabel, "modulate", Color.GREEN, 0.3)

func _play_outro() -> void:
	# --- SCALE-OUT OUTRO ANIMATION ---
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2.ZERO, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tw.finished
