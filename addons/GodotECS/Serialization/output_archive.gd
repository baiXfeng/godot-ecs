extends "archive.gd"

var _dict: Dictionary

func _init(dict: Dictionary) -> void:
	_dict = dict
	version = 0
	
# override
func _set_var(key: String, value) -> void:
	_dict[key] = value
	
# override
func _remove(key: String) -> bool:
	return _dict.erase(key)
	
# override
func _set_version(v: int) -> void:
	_dict["__VERSION__"] = v
	
# override
func _get_version() -> int:
	return _dict.get_or_add("__VERSION__", 0)
	
# override
func _copy_from(other) -> void:
	_dict = other._dict.duplicate()
	
