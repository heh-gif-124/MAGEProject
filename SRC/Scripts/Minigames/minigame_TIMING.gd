extends Control

var threshold : float = 0.0
var started : bool = false
var won : bool = false
var lost : bool = false
var current_number = 0

@export var bar : ProgressBar
@export var winlabel : Label
@export var numlabel : Label
@export var numtimer : Timer
@export var time : float = 1.0
@export var audio_1 : AudioStreamPlayer2D
@export var audio_2 : AudioStreamPlayer2D

@export_group("Lose Mechanics")
@export var max_mistakes : int = 3           # How many wrong hits before instant loss
@export var fail_label : Label               # Optional Label to display "FAILED!"
@export var max_wait_time : float = 2.5       # Lose if speed drops below this threshold



var current_mistakes : int = 0
var stylebox : StyleBoxFlat
var hydrant : Area3D
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
	if fail_label:
		fail_label.pivot_offset = fail_label.size / 2.0
		fail_label.visible = false

	numtimer.timeout.connect(func():
		audio_1.play()
		audio_1.pitch_scale = randf_range(1,1.4)
		if current_number >= 5:
			current_number = 0
		else:
			current_number += 1

		# Tiny pulse on every number tick
		_pulse_label(numlabel, Vector2(1.1, 1.1), 0.08, Color.WHITE)
	)

	Global.minigame.connect(func(hole):
		_reset_stuff()
		hydrant = hole
	)

func _process(_delta: float) -> void:
	if not Global.minigame_initiated or not started or won or lost:
		return

	numlabel.text = str(current_number)

	# Input handling
	if Input.is_action_just_pressed("interact"):
		audio_2.play()
		audio_2.pitch_scale = randf_range(1,1.4)
		_punch_effect()
		if current_number == 5:
			# --- CORRECT HIT ---
			threshold = min(threshold + 33.3, 100.0)
			current_number = 0
			numtimer.wait_time = max(0.1, numtimer.wait_time - 0.4)
			_tween_bar(threshold)
			_pulse_label(numlabel, Vector2(1.4, 1.4), 0.15, Color.GREEN)
		else:
			# --- WRONG HIT ---
			current_mistakes += 1
			threshold = max(threshold - 33.3, 0.0)
			current_number = 0
			numtimer.wait_time += 0.3
			_tween_bar(threshold)
			_shake_and_flash_label()

	# --- WIN CONDITION ---
	if threshold >= 99.0 and not won:
		_trigger_win()
		return

	# --- LOSE CONDITION ---
	# Triggers if player exceeds allowed mistakes OR timer becomes too slow
	if (current_mistakes >= max_mistakes or numtimer.wait_time >= max_wait_time) and not lost:
		_trigger_loss()
		return

func _reset_stuff() -> void:
	threshold = 0
	current_number = 0
	current_mistakes = 0
	won = false
	lost = false

	if winlabel:
		winlabel.visible = false
		winlabel.scale = Vector2(0.2, 0.2)
		winlabel.modulate.a = 0.0

	if fail_label:
		fail_label.visible = false
		fail_label.scale = Vector2(0.2, 0.2)
		fail_label.modulate.a = 0.0

	started = false
	visible = true
	bar.value = 0
	if stylebox:
		stylebox.bg_color = Color.RED

	# Intro Animation
	scale = Vector2.ZERO
	var intro_tween = create_tween()
	intro_tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	await get_tree().create_timer(0.5, true, false, true).timeout

	numtimer.wait_time = time
	numtimer.start()
	started = true

func _trigger_win() -> void:
	won = true
	numtimer.stop()
	Global.minigames_completed += 1

	if winlabel:
		winlabel.visible = true
	if stylebox:
		stylebox.bg_color = Color.GREEN

	_play_win_animation()

	await get_tree().create_timer(1.2, true, false, true).timeout
	Global.minigame_initiated = false
	Global.minigame_finished.emit.call_deferred()
	Global.currency += 250

	if is_instance_valid(hydrant):
		hydrant.queue_free()

	await _play_outro()
	queue_free()

func _trigger_loss() -> void:
	lost = true
	numtimer.stop()

	if stylebox:
		stylebox.bg_color = Color.DARK_RED

	if fail_label:
		fail_label.visible = true
		_play_fail_animation()
	else:
		_shake_and_flash_label()

	# Big shake on failure
	var shake_tw = create_tween()
	shake_tw.tween_property(self, "position", base_position + Vector2(12, 0), 0.05)
	shake_tw.tween_property(self, "position", base_position + Vector2(-12, 0), 0.05)
	shake_tw.tween_property(self, "position", base_position + Vector2(8, 0), 0.05)
	shake_tw.tween_property(self, "position", base_position, 0.05)

	await get_tree().create_timer(1.2, true, false, true).timeout

	# Cleanly reset minigame flag without completing the objective
	Global.minigame_initiated = false

	await _play_outro()
	queue_free()

# --- JUICE HELPER FUNCTIONS ---

func _punch_effect() -> void:
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

	var tw = create_tween()
	tw.tween_property(numlabel, "position", original_pos + Vector2(8, 0), 0.04)
	tw.tween_property(numlabel, "position", original_pos + Vector2(-8, 0), 0.04)
	tw.tween_property(numlabel, "position", original_pos + Vector2(4, 0), 0.04)
	tw.tween_property(numlabel, "position", original_pos, 0.04)

	var color_tw = create_tween()
	color_tw.tween_property(numlabel, "modulate", Color.WHITE, 0.3)

func _play_win_animation() -> void:
	if not winlabel: return
	winlabel.modulate.a = 1.0
	var tw = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(winlabel, "scale", Vector2(1.2, 1.2), 0.3)

	var color_tw = create_tween()
	color_tw.tween_property(winlabel, "modulate", Color.GREEN, 0.3)

func _play_fail_animation() -> void:
	if not fail_label: return
	fail_label.modulate.a = 1.0
	var tw = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(fail_label, "scale", Vector2(1.3, 1.3), 0.3)

	var color_tw = create_tween()
	color_tw.tween_property(fail_label, "modulate", Color.RED, 0.3)

func _play_outro() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2.ZERO, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tw.finished
