extends RefCounted
class_name ecs_event_center
	
var _event_dict: Dictionary
	
func add(name: String, listener: Object, function: String) -> bool:
	var dict = _get_event_dict(name)
	dict[listener] = function
	return true
	
func remove(name: String, listener: Object) -> bool:
	var dict = _get_event_dict(name)
	return dict.erase(listener)
	
func notify(name: String, value, context = null):
	send( ecs_event.new(name, value, context) )
	
func send(e: ecs_event):
	var dict = _get_event_dict(e.name)
	for listener in dict:
		listener.call(dict[listener], e)
	
func clear():
	_event_dict.clear()
	
func _get_event_dict(name: String) -> Dictionary:
	if not _event_dict.has(name):
		_event_dict[name] = {}
	return _event_dict[name]
	
