extends RefCounted

# ==============================================================================
# public
	
# data version for archive version compatibility
var version: int:
	set(v):
		_set_version(v)
	get:
		return _get_version()
	
# set variable
func set_var(key: String, value) -> void:
	_set_var(key, value)
	
# get variable
func get_var(key: String, defaultValue = null):
	return _get_var(key, defaultValue)
	
# remove variable
func remove(key: String) -> bool:
	return _remove(key)
	
# copy
func copy_from(other) -> void:
	_copy_from(other)
	
# ==============================================================================
# override
func _set_var(key: String, value) -> void:
	pass
	
# override
func _get_var(key: String, defaultValue):
	return defaultValue
	
# override
func _remove(key: String) -> bool:
	return false
	
# override
func _set_version(v: int) -> void:
	pass
	
# override
func _get_version() -> int:
	return 0
	
# override
func _copy_from(other) -> void:
	pass
	
