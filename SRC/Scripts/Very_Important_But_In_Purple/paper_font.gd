#extends Node
#
#var global_theme: Theme = preload("res://SRC/Themes/Main_Theme.tres")
#
#func _ready():
	#var custom_font = load("res://SRC/Sprites/PaperFont/paper_font.fnt")
	#
	## Apply globally
	#global_theme.default_font = custom_font
	#global_theme.default_font_size = 64 # Matches the 64 size in your .fnt file
	#get_tree().root.theme = global_theme
	#ThemeDB.fallback_font = custom_font
	#
	## Explicitly bind to specific node types to ensure buttons/labels grab it
	#global_theme.set_font("font", "Label", custom_font)
	#global_theme.set_font_size("font_size", "Label", 64)
	#
	#global_theme.set_font("font", "Button", custom_font)
	#global_theme.set_font_size("font_size", "Button", 64)
