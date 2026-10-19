extends Control

@export var pages: Array[Control] = []     # Drag page containers here in the Inspector
@export var next_button: Button            # Drag "Next" button here
@export var back_button: Button            # Drag "Back" button here
@export var game_start_scene: String

var current_page_index: int = 0

func _ready() -> void:
	# Connect button signals safely
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		
	# Initialize the view
	_update_pages()

func _on_next_pressed() -> void:
	if current_page_index < pages.size() - 1:
		current_page_index += 1
		_update_pages()
	else:
		SceneManager.load_scene(game_start_scene)

func _on_back_pressed() -> void:
	if current_page_index > 0:
		current_page_index -= 1
		_update_pages()

func _update_pages() -> void:
	# Loop through all pages and turn visibility on only for the current index
	for i in range(pages.size()):
		if pages[i]:
			pages[i].visible = (i == current_page_index)
			
	# Optional UI polish: Disable buttons at the boundaries
	if back_button:
		back_button.disabled = (current_page_index == 0)
	#if next_button:
		#next_button.disabled = (current_page_index == pages.size() - 1)
