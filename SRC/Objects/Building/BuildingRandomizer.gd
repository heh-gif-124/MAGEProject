extends Node3D

@export var bottom_building : Array[Texture2D]
@export var top_building : Array[Texture2D]
@export var windows : Array[Texture2D]
@export var doors : Array[Texture2D]

@export var top : Sprite3D
@export var bottom : Sprite3D
@export var window : Sprite3D
@export var door : Sprite3D

@export_group("Occlusion Settings")
@export var detection_area : Area3D
@export var hidden_alpha : float = 0.3  # Opacity when behind (30%)
@export var fade_duration : float = 0.2  # Speed of the fade effect

var _fade_tween : Tween

func _ready() -> void:
	_randomize()

	# Connect detection signals dynamically if assigned
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)

func _randomize() -> void:
	top.texture = top_building.pick_random()
	bottom.texture = bottom_building.pick_random()
	window.texture = windows.pick_random()
	door.texture = doors.pick_random()

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		_fade_sprites(hidden_alpha)

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		_fade_sprites(1.0)

func _fade_sprites(target_alpha: float) -> void:
	# Kill previous running tween to prevent conflicts during quick exits/entries
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	_fade_tween = create_tween().set_parallel(true)

	var sprites : Array[Sprite3D] = [top, bottom, window, door]
	for sprite in sprites:
		if is_instance_valid(sprite):
			var target_color := sprite.modulate
			target_color.a = target_alpha
			_fade_tween.tween_property(sprite, "modulate", target_color, fade_duration)
