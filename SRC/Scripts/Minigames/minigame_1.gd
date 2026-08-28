extends Control

var threshold : float = 0.0
var started : bool = false
var won : bool = false

@export var bar : ProgressBar
@export var winlabel : Label
@export var decay_rate : float = 20.0 # Points lost per second
var stylebox : StyleBoxFlat
func _ready() -> void:
	stylebox = bar.get_theme_stylebox("fill") as StyleBoxFlat
	Global.minigame.connect(func():
		stylebox.bg_color = Color.GRAY
		threshold = 50.0
		winlabel.visible = false
		started = false
		won = false
		visible = true
		await get_tree().create_timer(0.5, true, false, true).timeout
		started = true
	)

func _physics_process(delta: float) -> void:
	if not Global.minigame_initiated or not started or won:
		return

	# Handle Player Input
	if Input.is_action_just_pressed("interact"):
		threshold += 15.0

	# Check Win Condition
	if threshold >= 100.0:
		won = true
		Global.minigames_completed += 1
		winlabel.visible = true
		stylebox.bg_color = Color.GREEN
		await get_tree().create_timer(1.5, true, false, true).timeout
		Global.minigame_initiated = false
		
		visible = false
		return

	# Apply Frame-Independent Decay (Only runs while still active and not won)
	_reduce_threshold(delta)
	stylebox.bg_color = Color.RED
	# Check Loss Condition
	if threshold <= 0.0:
		Global.minigame_initiated = false
		visible = false

func _process(_delta: float) -> void:
	bar.value = threshold

func _reduce_threshold(delta: float) -> void:
	threshold -= decay_rate * delta
