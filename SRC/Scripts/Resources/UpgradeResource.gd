extends Resource
class_name upgrade
var name
var cost
var id

func _init(pname:String,pid:String,pcost:float=100.0) -> void:
	name = pname
	cost = pcost
	id = pid
