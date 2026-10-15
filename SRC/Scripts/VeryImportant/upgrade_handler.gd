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
	Global.buy.connect(func(upgrade_id):

		if upgrade_id == "DDH":
			print("Bought Dashing")
			Global.upgrade_list.append(upgrade_id)
		elif upgrade_id == "MMI":
			print("bought Minimap")
			Global.upgrade_list.append(upgrade_id)
		elif upgrade_id == "SSL":
			print("bought Slow down")
			Global.upgrade_list.append(upgrade_id)
		print(Global.upgrade_list)
	)
