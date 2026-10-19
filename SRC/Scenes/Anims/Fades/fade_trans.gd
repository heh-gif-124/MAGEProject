# Inside Fade_Trans.gd
extends ColorRect

signal fade_completed(StringName)

func fade_in() -> void:
	show()
	$AnimationPlayer.play("Fade_In")

func fade_out() -> void:
	show()
	$AnimationPlayer.play("Fade_Out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"Fade_In":
		fade_completed.emit(anim_name)
	elif anim_name == &"Fade_Out":
		fade_completed.emit(anim_name)
		hide() # Hide overlay after fading out so UI elements behind it are clickable
