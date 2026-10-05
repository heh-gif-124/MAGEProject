extends Resource
class_name UpgradeRes
var upname
var upcost
var upid
var updesc
func _init(pname:String,pid:String,pdesc,pcost:float=100.0) -> void:
	upname = pname
	upcost = pcost
	updesc = pdesc
	upid = pid
