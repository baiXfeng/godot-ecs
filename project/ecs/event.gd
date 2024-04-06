extends Reference
class_name ecs_event
	
var _event_dict: Dictionary
	
func add_listener(name: String, object: Object) -> bool:
	var dict = _get_event_dict(name)
	dict[object] = true
	return true
	
func remove_listener(name: String, object: Object) -> bool:
	var dict = _get_event_dict(name)
	return dict.erase(object)
	
func fetch_listener(fetcher: FuncRef, name: String, param):
	var dict = _get_event_dict(name)
	for listener in dict:
		fetcher.call_func(listener, name, param)
	
func clear():
	_event_dict.clear()
	
func _get_event_dict(name: String) -> Dictionary:
	if not _event_dict.has(name):
		_event_dict[name] = {}
	return _event_dict[name]
	
