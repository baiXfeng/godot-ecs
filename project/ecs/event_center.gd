extends RefCounted
class_name ecs_event_center
	
var _event_dict: Dictionary
	
func add(name: String, listener: Object, function: String) -> bool:
	return add_callable(name, Callable(listener, function))
	
func add_callable(name: String, c: Callable) -> bool:
	var dict = _get_event_dict(name)
	dict[c.get_object()] = c
	return true
	
func remove(name: String, listener: Object) -> bool:
	var dict = _get_event_dict(name)
	return dict.erase(listener)
	
func remove_callable(name: String, c: Callable) -> bool:
	var dict = _get_event_dict(name)
	return dict.erase(c.get_object())
	
func notify(name: String, value):
	send( ecs_event.new(name, value) )
	
func send(e: ecs_event):
	var dict = _get_event_dict(e.name)
	for key in dict:
		dict[key].call(e)
	
func clear():
	_event_dict.clear()
	
func _get_event_dict(name: String) -> Dictionary:
	if not _event_dict.has(name):
		_event_dict[name] = {}
	return _event_dict[name]
	
