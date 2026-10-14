extends Resource
class_name UpgradeRes
var upname
var upcost
var upid
var updesc
var uplodesc
func _init(pname:String,pid:String,pdesc,plongdesc:String="Blank",pcost:float=100.0) -> void:
	upname = pname
	upcost = pcost
	updesc = pdesc
	uplodesc = plongdesc
	upid = pid
