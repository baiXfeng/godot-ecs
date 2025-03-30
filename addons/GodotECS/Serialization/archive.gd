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
func set_var(key: String, value):
	_set_var(key, value)
	
# get variable
func get_var(key: String, defaultValue = null):
	return _get_var(key, defaultValue)
	
# remove variable
func remove(key: String):
	pass
	
# copy
func copy_from(other):
	_copy_from(other)
	
# ==============================================================================
# override
func _set_var(key: String, value):
	pass
	
# override
func _get_var(key: String, defaultValue):
	return defaultValue
	
# override
func _remove(key: String):
	pass
	
# override
func _set_version(v: int):
	pass
	
# override
func _get_version() -> int:
	return 0
	
# override
func _copy_from(other):
	pass
	
