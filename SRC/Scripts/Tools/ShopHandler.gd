extends Node

@export var shop_thing : Upgrade_shop
@export var to_a: VBoxContainer
@export var to_b: VBoxContainer
@export var exit_buton : TextureButton
@export var anim_player : AnimationPlayer

# Master pool of all possible upgrades
var upgrade_pool : Array = [slow_down.new(), Minimap.new(), Dash.new(), DoubleJump.new()]

func _ready() -> void:
	exit_buton.pressed.connect(func():
		anim_player.play("exit")
		Global.shop_exited.emit()
	)

	exit_buton.pivot_offset = exit_buton.size / 2

	exit_buton.mouse_entered.connect(func():
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(exit_buton, "scale", Vector2(1.2, 1.2), 0.15)
		tween.tween_property(exit_buton, "rotation_degrees", randf_range(-10, 10), 0.15)
	)

	exit_buton.mouse_exited.connect(func():
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween.tween_property(exit_buton, "scale", Vector2(1.0, 1.0), 0.2)
		tween.tween_property(exit_buton, "rotation_degrees", 0.0, 0.2)
	)

	# Shuffle the pool so upgrades appear in random order every time
	upgrade_pool.shuffle()

	# Keep track of which upgrade we are handing out next
	var pool_index : int = 0

	# Populate Container A (2 items)
	for i in 2:
		if pool_index >= upgrade_pool.size():
			break # Stop if we run out of unique upgrades

		var y = shop_thing.duplicate()
		y.upgrade_data = upgrade_pool[pool_index] # Assign unique upgrade
		y.visible = true
		to_a.add_child.call_deferred(y)
		pool_index += 1

	# Populate Container B (2 items)
	for i in 2:
		if pool_index >= upgrade_pool.size():
			break # Stop if we run out of unique upgrades

		var y = shop_thing.duplicate()
		y.upgrade_data = upgrade_pool[pool_index] # Assign unique upgrade
		y.visible = true
		to_b.add_child.call_deferred(y)
		pool_index += 1

func _process(delta: float) -> void:
	pass

func _clear():
	queue_free()
