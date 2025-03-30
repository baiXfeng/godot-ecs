extends RefCounted
class_name ECSWorldPack

var _dict: Dictionary

func _init(dict: Dictionary) -> void:
	_dict = dict
	
func data() -> Dictionary:
	return _dict.duplicate()
	
