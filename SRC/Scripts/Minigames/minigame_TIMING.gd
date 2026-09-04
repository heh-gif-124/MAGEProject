extends Control

var threshold : float = 0.0
var started : bool = false
var won : bool = false
var current_number = 0
@export var bar : ProgressBar
@export var winlabel : Label
@export var numlabel : Label
@export var numtimer : Timer
var stylebox : StyleBoxFlat
func _ready() -> void:
	stylebox = bar.get_theme_stylebox("fill") as StyleBoxFlat
	numtimer.timeout.connect(func():
		if current_number >= 5:
			current_number = 0
		else:
			current_number += 1
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	numlabel.text = str(current_number)
	bar.value = threshold
	if Input.is_action_just_pressed("interact") and current_number == 5:
		threshold += ceil(33.3)
		current_number = 0
		numtimer.wait_time -= 0.3

	if threshold >= 100.0:
		won = true
		Global.minigames_completed += 1
		winlabel.visible = true
		stylebox.bg_color = Color.GREEN
		await get_tree().create_timer(1.5, true, false, true).timeout
		Global.minigame_initiated = false

		visible = false
		return


func _reset_stuff():
		#use at the start of every minigame
	threshold = 0
	current_number = 0
	winlabel.visible = false
	numtimer.start(0)
	started = false
	won = false
	visible = true
	await get_tree().create_timer(0.5, true, false, true).timeout
	started = true
