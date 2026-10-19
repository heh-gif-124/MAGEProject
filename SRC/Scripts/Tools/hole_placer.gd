extends Node
class_name HolePlacer

signal holes_spawned
signal holes_cleared

@export_category("Spawning Setup")
@export var hole_scene: PackedScene
@export var hole_container: Node3D
@export var hole_amount: int = 5

@export_category("Random Scatter Variance")
@export var position_offset_radius: float = 0.75  # Max distance offset from the Marker3D
@export var randomize_rotation_y: bool = true       # Spin them randomly on the Y axis
@export var scale_variance: float = 0.2             # Random scale wiggle (+/- 20%)

@export_category("Juice & Animation")
@export var staggered_spawn: bool = true
@export var spawn_delay: float = 0.08
@export var spawn_duration: float = 0.35

var minigame_children: Array[Node3D] = []

func _ready() -> void:
	call_deferred("_place_holes")


func reset_holes() -> void:
	await _remove_holes_animated()
	_place_holes()


func _place_holes() -> void:
	if not hole_scene or not hole_container:
		push_warning("HolePlacer: Missing hole_scene or hole_container reference.")
		return

	# Collect all valid Marker3D children
	var spawn_markers: Array[Marker3D] = []
	for child in get_children():
		if child is Marker3D:
			spawn_markers.append(child)

	if spawn_markers.is_empty():
		push_warning("HolePlacer: No Marker3D children found!")
		return

	# Shuffle markers for random point selection
	spawn_markers.shuffle()
	var count = mini(hole_amount, spawn_markers.size())

	for i in range(count):
		var marker = spawn_markers[i]
		var g = hole_scene.instantiate()

		if "id" in g:
			g.id = i + 1

		# --- 1. RANDOM SCATTER LOGIC ---
		var target_pos = marker.global_position
		if position_offset_radius > 0.0:
			var random_angle = randf() * TAU
			var random_dist = randf_range(0.0, position_offset_radius)
			target_pos.x += cos(random_angle) * random_dist
			target_pos.z += sin(random_angle) * random_dist

		g.global_position = target_pos

		if randomize_rotation_y:
			g.global_rotation.y = randf_range(0.0, TAU)

		var final_scale = Vector3.ONE
		if scale_variance > 0.0:
			var scale_factor = randf_range(1.0 - scale_variance, 1.0 + scale_variance)
			final_scale = Vector3.ONE * scale_factor

		hole_container.add_child(g)
		minigame_children.append(g)

		# --- 2. ANIMATED SPAWN JUICE ---
		_animate_hole_spawn(g, final_scale)

		if staggered_spawn and spawn_delay > 0.0:
			await get_tree().create_timer(spawn_delay).timeout

	holes_spawned.emit()


func _animate_hole_spawn(hole: Node3D, target_scale: Vector3) -> void:
	hole.scale = Vector3.ZERO

	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(hole, "scale", target_scale, spawn_duration)\
		.from(Vector3.ZERO)\
		.set_trans(Tween.TRANS_ELASTIC)


func _remove_holes_animated() -> void:
	if minigame_children.is_empty():
		return

	var delete_tween := create_tween().set_parallel(true)

	for hole in minigame_children:
		if is_instance_valid(hole):
			delete_tween.tween_property(hole, "scale", Vector3.ZERO, 0.2)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_IN)

	await delete_tween.finished

	for hole in minigame_children:
		if is_instance_valid(hole):
			hole.queue_free()

	minigame_children.clear()
	holes_cleared.emit()
