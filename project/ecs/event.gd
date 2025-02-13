extends RefCounted
class_name ECSEvent

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
	
var event_center: ECSEventCenter:
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
	return "ECSEvent(\"%s\", %s)" % [_name, _data]
	
