extends "archive.gd"

var _dict: Dictionary

func _init(dict: Dictionary) -> void:
	_dict = dict
	
# override
func _get_var(key: String, defaultValue):
	if _dict.has(key):
		return _dict[key]
	return defaultValue
	
# override
func _get_version() -> int:
	return _dict.get_or_add("__VERSION__", 0)
	
