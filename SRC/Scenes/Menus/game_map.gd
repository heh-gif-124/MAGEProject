extends Node

@export var marker_scene: PackedScene ## The marker scene you want to spawn
@export var spawn_areas: Array[Polygon2D]    ## Your Polygon2D node defining the region
@export var spawn_count: int = 100    ## How many markers to spawn

func _ready() -> void:
	spawn_random_markers()

func spawn_random_markers() -> void:
	if spawn_areas.is_empty() or not marker_scene:
		print("Missing spawn areas or marker scene!")
		return
		
	var spawned = 0
	var attempts = 0
	var max_attempts = 3000 # Increased safety limit for multiple shapes
	
	while spawned < spawn_count and attempts < max_attempts:
		attempts += 1
		
		# 1. Pick a random Polygon2D from our list
		var active_polygon = spawn_areas.pick_random() as Polygon2D
		if not active_polygon or active_polygon.polygon.is_empty():
			continue
			
		var poly_points = active_polygon.polygon
		
		# 2. Find the bounding box of that specific polygon
		var min_pos = poly_points[0]
		var max_pos = poly_points[0]
		for pt in poly_points:
			min_pos.x = min(min_pos.x, pt.x)
			min_pos.y = min(min_pos.y, pt.y)
			max_pos.x = max(max_pos.x, pt.x)
			max_pos.y = max(max_pos.y, pt.y)
			
		# 3. Generate a random point inside this polygon's bounding box
		var random_point = Vector2(
			randf_range(min_pos.x, max_pos.x),
			randf_range(min_pos.y, max_pos.y)
		)
		
		# 4. Check if the point is actually inside the polygon shape
		if Geometry2D.is_point_in_polygon(random_point, poly_points):
			var marker = marker_scene.instantiate() as Button
			if not marker:
				return
				
			# Parent the marker to the polygon so it moves/scales with that specific map region
			active_polygon.add_child(marker)
			
			# Center the button on the point
			marker.position = random_point - (marker.size / 2.0)
			
			# Connect the click event
			marker.pressed.connect(_on_marker_clicked.bind(marker))
			
			spawned += 1
			
	print("Successfully spawned ", spawned, " markers across ", spawn_areas.size(), " polygon areas.")

func _on_marker_clicked(marker: Button) -> void:
	print("Clicked marker at local position: ", marker.position)
