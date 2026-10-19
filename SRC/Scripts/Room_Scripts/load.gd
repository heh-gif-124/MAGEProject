extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var progress_label: Label = $ProgressPercent

var all_paths: Array[String] = []
var loading_started: bool = false

func _ready() -> void:
	%Fade_Trans.fade_out()
	%AnimatedSprite2D.play("run")
	if SceneManager.target_scene.is_empty():
		return
	
	# Combine the target scene and all extra asset paths into one list
	all_paths.append(SceneManager.target_scene)
	for asset in SceneManager.extra_assets:
		if not all_paths.has(asset):
			all_paths.append(asset)
	
	# Request background threaded load for every single item
	for path in all_paths:
		ResourceLoader.load_threaded_request(path)
	
	loading_started = true

func _process(_delta: float) -> void:
	if not loading_started:
		return
	
	var total_items = all_paths.size()
	var completed_weight = 0.0
	var progress_array: Array = []
	
	# Check status of all items to calculate accurate total progress
	for path in all_paths:
		var status = ResourceLoader.load_threaded_get_status(path, progress_array)
		
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				completed_weight += 1.0
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if progress_array.size() > 0:
					completed_weight += progress_array[0]
			ResourceLoader.THREAD_LOAD_FAILED:
				print("Loading Error: Failed to load -> ", path)
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				print("Loading Error: Invalid resource -> ", path)
	
	# Calculate percentage across all items (scenes + assets)
	var real_percentage = (completed_weight / float(total_items)) * 100.0
	
	# If real loading is 100% done, force target to 100. Otherwise, lag slightly behind real progress 
	# so it has room to catch up gracefully.
	var speed = 60.0 # Adjust this to make it faster or slower
	
	var target_value = real_percentage
	if completed_weight >= float(total_items):
		target_value = 100.0 # Force complete when actually done
		speed = 300.0
	
	# move_toward shifts progress_bar.value toward target_value at a steady pixel/value rate per second
	progress_bar.value = move_toward(progress_bar.value, target_value, _delta * speed)
	
	if progress_label:
		progress_label.text = "%d%%" % int(progress_bar.value)
	
	if has_node("ProgressBar/AnimatedSprite2D"):
		var sprite = $ProgressBar/AnimatedSprite2D
		
		# Calculate ratio from 0.0 to 1.0 based on the bar's current value
		var ratio = (progress_bar.value - progress_bar.min_value) / (progress_bar.max_value - progress_bar.min_value)
		var fill_width = ratio * progress_bar.size.x
		
		sprite.position.x = fill_width 
		sprite.position.y = -progress_bar.size.y - 10
	
	if completed_weight >= float(total_items) and progress_bar.value >= 100.0 and loading_started:
		await get_tree().create_timer(0.2).timeout
		
		loading_started = false
		
		var target_path = SceneManager.target_scene
		
		if target_path.is_empty():
			push_error("Transition Error: SceneManager.target_scene was already empty!")
			return
			
		# Retrieve the fully loaded packed scene
		var packed_scene = ResourceLoader.load_threaded_get(target_path)
		
		if packed_scene:
			print("Packed scene retrieved successfully. Changing scene...")
			# Clear out manager variables
			SceneManager.target_scene = ""
			SceneManager.extra_assets.clear()
			
			get_tree().change_scene_to_packed(packed_scene)
		else:
			push_error("Loading Error: ResourceLoader returned null for path: " + target_path)

func _on_fade_completed(anim_name: StringName) -> void:
	print("Animation finished callback received: ", anim_name)
