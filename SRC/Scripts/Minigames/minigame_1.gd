extends Control

var threshold : float = 0.0
var started : bool = false
var won : bool = false
var lost : bool = false
var calibrating : bool = false

@export var bar : ProgressBar
@export var winlabel : Label
@export var fail_label : Label              # Drag your "FAILED!" label here in the Inspector
@export var decay_rate : float = 20.0       # Points lost per second
var hydrant : Area3D
var stylebox : StyleBoxFlat

# For shake effects
var base_position : Vector2

func _ready() -> void:
	stylebox = bar.get_theme_stylebox("fill") as StyleBoxFlat
	pivot_offset = size / 2.0
	base_position = position

	if winlabel:
		winlabel.pivot_offset = winlabel.size / 2.0
	if fail_label:
		fail_label.pivot_offset = fail_label.size / 2.0
		fail_label.visible = false

	Global.minigame.connect(func(hole):
		_reset_stuff()
		hydrant = hole
	)

func _physics_process(delta: float) -> void:
	if calibrating:
		# Cool fluctuating calibration effect with smooth wave
		threshold = 50.0 + sin(Time.get_ticks_msec() * 0.015) * 35.0
		stylebox.bg_color = Color.YELLOW.lerp(Color.ORANGE, abs(sin(Time.get_ticks_msec() * 0.02)))
		return

	if not Global.minigame_initiated or not started or won or lost:
		return

	# Handle Player Input with Juice Punch
	if Input.is_action_just_pressed("interact"):
		threshold += 15.0
		_punch_effect()

	# Check Win Condition
	if threshold >= 100.0:
		won = true
		Global.minigames_completed += 1
		stylebox.bg_color = Color.GREEN

		# Explode win label onto screen
		_play_win_juice()

		await get_tree().create_timer(1.5, true, false, true).timeout

		Global.minigame_initiated = false
		Global.minigame_finished.emit.call_deferred()
		Global.currency += 30
		print("Money: " + str(Global.currency))

		if is_instance_valid(hydrant):
			hydrant.queue_free()

		await _play_outro()
		queue_free()
		return

	# Apply Frame-Independent Decay
	_reduce_threshold(delta)

	# Dynamic color and danger shake when low
	if threshold < 25.0:
		stylebox.bg_color = Color.DARK_RED
		_apply_danger_shake()
	else:
		stylebox.bg_color = Color.RED

	# Check Loss Condition
	if threshold <= 0.0 and not lost:
		lost = true
		stylebox.bg_color = Color.DARK_RED

		# Play Fail Juice FX
		_play_fail_juice()

		# Aggressive failure shake
		var shake_tw = create_tween()
		shake_tw.tween_property(self, "position", base_position + Vector2(12, 0), 0.05)
		shake_tw.tween_property(self, "position", base_position + Vector2(-12, 0), 0.05)
		shake_tw.tween_property(self, "position", base_position + Vector2(8, 0), 0.05)
		shake_tw.tween_property(self, "position", base_position, 0.05)

		await get_tree().create_timer(1.2, true, false, true).timeout

		Global.minigame_initiated = false
		await _play_outro()
		queue_free()
		return

func _process(_delta: float) -> void:
	bar.value = threshold

func _reduce_threshold(delta: float) -> void:
	threshold -= decay_rate * delta

func _reset_stuff():
	stylebox.bg_color = Color.YELLOW
	if winlabel:
		winlabel.visible = false
		winlabel.scale = Vector2.ZERO
		winlabel.modulate.a = 0.0

	if fail_label:
		fail_label.visible = false
		fail_label.scale = Vector2.ZERO
		fail_label.modulate.a = 0.0

	started = false
	won = false
	lost = false
	visible = true
	position = base_position

	# Scale-In Intro with Spring Bounce
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	calibrating = true
	await get_tree().create_timer(1.5, true, false, true).timeout

	calibrating = false
	threshold = 50.0
	started = true

func _punch_effect() -> void:
	# Quick scale punch when interacting
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.08, 1.08), 0.05).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)

func _apply_danger_shake() -> void:
	# Jitters the control when health/threshold is critically low
	position = base_position + Vector2(randf_range(-3, 3), randf_range(-3, 3))

func _play_win_juice() -> void:
	if not winlabel: return
	winlabel.visible = true
	winlabel.modulate.a = 1.0

	var tw = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(winlabel, "scale", Vector2(1.3, 1.3), 0.3)
	tw.tween_property(winlabel, "rotation_degrees", randf_range(-5, 5), 0.3)

func _play_fail_juice() -> void:
	if not fail_label: return
	fail_label.visible = true
	fail_label.modulate.a = 1.0

	var tw = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(fail_label, "scale", Vector2(1.3, 1.3), 0.3)
	tw.tween_property(fail_label, "modulate", Color.RED, 0.3)

func _play_outro() -> void:
	position = base_position # Reset shake offset before scaling down
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tween.finished
