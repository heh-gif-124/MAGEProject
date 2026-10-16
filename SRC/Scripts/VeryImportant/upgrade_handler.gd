extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Global.upgrade_list:
		if i == "DDH":
			var t = Dash.new()
			add_child.call_deferred(t)
		elif i == "SSL":
			var t = slow_down.new()
			add_child.call_deferred(t)
		elif i == "DDJ":
			var t = DoubleJump.new()
			add_child.call_deferred(t)
	Global.buy.connect(func(upgrade_id):
		print(Global.upgrade_list)
	)
