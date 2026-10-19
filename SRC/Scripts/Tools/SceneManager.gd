extends Node

const MAIN_MENU = "res://SRC/Scenes/Menus/Main_Menu.tscn"
const LOADING_SCREEN_PATH: String = "res://SRC/Scenes/Anims/Loading_Screen.tscn"

# Stores what we want to load next
var target_scene: String = ""
var extra_assets: Array[String] = []

func _ready() -> void:
	load_scene(MAIN_MENU)

# Call this from ANYWHERE in the game to transition
func load_scene(scene_path: String, assets_to_preload: Array[String] = []) -> void:
	target_scene = scene_path
	extra_assets = assets_to_preload
	
	# Check if the main scene is already fully loaded in memory!
	var dummy_progress = []
	var status = ResourceLoader.load_threaded_get_status(scene_path, dummy_progress)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		# It's already cached! Skip the loading screen entirely.
		print("Scene was preloaded silently. Instant transition!")
		var packed_scene = ResourceLoader.load_threaded_get(scene_path)
		target_scene = ""
		extra_assets.clear()
		get_tree().change_scene_to_packed.call_deferred(packed_scene)
	else:
		# Not fully loaded yet, go to the loading screen as normal fallback
		get_tree().change_scene_to_file.call_deferred(LOADING_SCREEN_PATH)

# Call this early (e.g., when hovering over the "Play" button or entering the main menu)
func load_scene_silently(scene: String, extra_assets: Array[String] = []) -> void:
	# Just request it in the background without changing scenes
	ResourceLoader.load_threaded_request(scene)
	for asset in extra_assets:
		ResourceLoader.load_threaded_request(asset)
	print("Silently preloading in background: ", scene)
