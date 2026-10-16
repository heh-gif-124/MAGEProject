extends Control

var started : bool = false
var won : bool = false

@export var win_area : Area2D
@export var mini_player : CharacterBody2D
@export var winlabel : Label
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

	Global.minigame.connect(func(hole):
		_reset_stuff()
		hydrant = hole
	)

func _physics_process(delta: float) -> void:
	if started and not won:
		if Input.is_action_just_pressed("ui_right"):
			mini_player.velocity.x += 30
			# Minor stretch juice on input
			_juice_player_stretch(Vector2(1.2, 0.8), 0.08)

		# Check Win Condition when stopped
		if win_area.has_overlapping_bodies() and tape_stopped:
			won = true
			Global.minigames_completed += 1

			# Juicy Win Animation
			_play_win_juice()

			await get_tree().create_timer(1.5, true, false, true).timeout
			Global.minigame_initiated = false
			Global.minigame_finished.emit.call_deferred()
			Global.currency += 100
			print("Money: " + str(Global.currency))

			if is_instance_valid(hydrant):
				hydrant.queue_free()

			await _play_outro()
			queue_free()
			return

	mini_player.move_and_slide()

	# Stopping action with juicy feedback
	if Input.is_action_just_pressed("interact") and started and not tape_stopped:
		mini_player.velocity.x = 0
		tape_stopped = true
		_punch_effect()
		_juice_player_stretch(Vector2(0.8, 1.3), 0.15) # Squish/stretch impact frame

func _reset_stuff() -> void:
	tape_stopped = false
	won = false
	started = false
	visible = true
	position = base_position

	if winlabel:
		winlabel.visible = false
		winlabel.scale = Vector2(0.2, 0.2)
		winlabel.modulate.a = 0.0

	if mini_player:
		mini_player.position = Vector2(-560.0, 0)
		mini_player.scale = Vector2.ONE

	# --- SCALE-IN INTRO ANIMATION ---
	scale = Vector2.ZERO
	var intro_tween = create_tween()
	intro_tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	await get_tree().create_timer(0.5, true, false, true).timeout
	started = true

# --- JUICE HELPER FUNCTIONS ---

func _punch_effect() -> void:
	# Quick scale punch on the entire UI control window
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

func _play_outro() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2.ZERO, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tw.finished
