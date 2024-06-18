extends RefCounted
class_name ecs_event

var name: String: get = _get_name, set = _set_name
var data : get = _get_data, set = _set_data

# ==============================================================================
# private
var _name: String
var _data
	
func _init(n, d):
	_name = n
	_data = d
	
func _set_name(v):
	pass
	
func _get_name() -> String:
	return _name
	
func _set_data(v):
	pass
	
func _get_data():
	return _data
	
func _to_string():
	return "ecs_event(\"%s\", %s)" % [_name, _data]
	
