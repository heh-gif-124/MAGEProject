extends Control

var started : bool = false
var won : bool = false
var lost : bool = false

@export var win_area : Area2D
@export var mini_player : CharacterBody2D
@export var winlabel : Label
@export var faillabel : Label
@export var countdown : Timer
@export var timerlabel : Label
var hydrant : Area3D
var stylebox : StyleBoxFlat
@export var tape_stopped : bool = false

# For juicing
var base_position : Vector2

func _ready() -> void:
	pivot_offset = size / 2.0
	base_position = position

	if winlabel:
		winlabel.pivot_offset = winlabel.size / 2.0
		winlabel.visible = false
	if faillabel:
		faillabel.pivot_offset = faillabel.size / 2.0
		faillabel.visible = false

	Global.minigame.connect(func(hole):
		_reset_stuff()
		hydrant = hole
	)

	if countdown:
		countdown.timeout.connect(func():
			if not won and not lost:
				_trigger_loss()
		)

func _physics_process(delta: float) -> void:
	timerlabel.text = str(ceil(countdown.time_left))
	if started and not won and not lost:
		if Input.is_action_just_pressed("ui_right"):
			mini_player.velocity.x += 30
			# Minor stretch juice on input
			_juice_player_stretch(Vector2(1.2, 0.8), 0.08)

		# Check Win Condition when stopped inside the area
		if win_area.has_overlapping_bodies() and tape_stopped:
			won = true
			if countdown: countdown.stop()
			Global.minigames_completed += 1

			# Juicy Win Animation
			_play_win_juice()

			await get_tree().create_timer(1.5, true, false, true).timeout
			Global.minigame_initiated = false
			Global.minigame_finished.emit.call_deferred()
			Global.currency += 50
			print("Money: " + str(Global.currency))

			if is_instance_valid(hydrant):
				hydrant.queue_free()

			await _play_outro()
			queue_free()
			return

	# Apply motion and check for wall collisions using CharacterBody2D built-in slide collision data
	mini_player.move_and_slide()

	if started and not won and not lost and mini_player.get_slide_collision_count() > 0:
		# Hit a wall / obstacle before reaching the win zone!
		_trigger_loss()
		return

	# Stopping action (Interact button pressed)
	if Input.is_action_just_pressed("interact") and started and not tape_stopped and not lost:
		mini_player.velocity.x = 0
		tape_stopped = true
		_punch_effect()
		_juice_player_stretch(Vector2(0.8, 1.3), 0.15) # Squish/stretch impact frame

		# --- LOSE CONDITION: STOPPED TOO EARLY ---
		# If the player pressed interact, but is NOT overlapping the win area, they fail instantly!
		if not win_area.has_overlapping_bodies():
			_trigger_loss()
			return

func _reset_stuff() -> void:
	tape_stopped = false
	won = false
	lost = false
	visible = true
	position = base_position

	if winlabel:
		winlabel.visible = false
		winlabel.scale = Vector2(0.2, 0.2)
		winlabel.modulate.a = 0.0

	if faillabel:
		faillabel.visible = false
		faillabel.scale = Vector2(0.2, 0.2)
		faillabel.modulate.a = 0.0

	if mini_player:
		mini_player.position = Vector2(-560.0, 0)
		mini_player.scale = Vector2.ONE
		mini_player.velocity = Vector2.ZERO

	# --- SCALE-IN INTRO ANIMATION ---
	scale = Vector2.ZERO
	var intro_tween = create_tween()
	intro_tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	await get_tree().create_timer(0.5, true, false, true).timeout
	started = true

	if countdown:
		countdown.start()

# --- JUICE HELPER FUNCTIONS ---

func _punch_effect() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.06, 1.06), 0.04).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.08).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)

func _juice_player_stretch(target_scale: Vector2, duration: float) -> void:
	if not mini_player: return
	var tw = create_tween()
	tw.tween_property(mini_player, "scale", target_scale, duration * 0.5).set_ease(Tween.EASE_OUT)
	tw.tween_property(mini_player, "scale", Vector2.ONE, duration * 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)

func _play_win_juice() -> void:
	if not winlabel: return
	winlabel.visible = true
	winlabel.modulate.a = 1.0

	var tw = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(winlabel, "scale", Vector2(1.3, 1.3), 0.3)
	tw.tween_property(winlabel, "rotation_degrees", randf_range(-6, 6), 0.3)

	var color_tw = create_tween()
	color_tw.tween_property(winlabel, "modulate", Color.GREEN, 0.3)

func _play_fail_animation() -> void:
	if not faillabel: return
	faillabel.visible = true
	faillabel.modulate.a = 1.0

	var tw = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(faillabel, "scale", Vector2(1.3, 1.3), 0.3)

	var color_tw = create_tween()
	color_tw.tween_property(faillabel, "modulate", Color.RED, 0.3)

func _shake_and_flash_label() -> void:
	if not mini_player: return
	var original_pos = mini_player.position
	var tw = create_tween()
	tw.tween_property(mini_player, "position", original_pos + Vector2(8, 0), 0.04)
	tw.tween_property(mini_player, "position", original_pos + Vector2(-8, 0), 0.04)
	tw.tween_property(mini_player, "position", original_pos, 0.04)

func _trigger_loss() -> void:
	lost = true
	if countdown: countdown.stop()

	if stylebox:
		stylebox.bg_color = Color.DARK_RED

	if faillabel:
		faillabel.visible = true
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

func _play_outro() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2.ZERO, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tw.finished
