extends RefCounted
class_name ecs_event

var name: String:
	set(v):
		pass
	get:
		return _name
	
var data:
	set(v):
		pass
	get:
		return _data
	
var event_center: ecs_event_center:
	set(v):
		pass
	get:
		return _event_center.get_ref()

# ==============================================================================
# private
var _name: String
var _data
var _event_center: WeakRef
	
func _init(n, d):
	_name = n
	_data = d
	
func _to_string():
	return "ecs_event(\"%s\", %s)" % [_name, _data]
	
