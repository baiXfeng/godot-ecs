extends Reference
class_name ecs_event

var name: String setget _set_name, _get_name
var data setget _set_data, _get_data
var context setget _set_context, _get_context

# ==============================================================================
# private
var _name: String
var _data
var _context: WeakRef
	
func _init(n, d, c = null):
	_name = n
	_data = d
	_context = weakref(c)
	
func _set_name(v):
	pass
	
func _get_name() -> String:
	return _name
	
func _set_data(v):
	pass
	
func _get_data():
	return _data
	
func _set_context(c):
	pass
	
func _get_context():
	return _context.get_ref()
	
func _to_string():
	return "ecs_event(\"%s\", %s)" % [name, _data]
	
