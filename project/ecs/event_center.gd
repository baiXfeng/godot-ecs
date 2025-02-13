extends RefCounted
class_name ECSEventCenter
	
var _event_dict: Dictionary
	
func add_callable(name: String, c: Callable) -> bool:
	return _get_event_listener(name).add(c)
	
func remove_callable(name: String, c: Callable) -> bool:
	return _get_event_listener(name).remove(c)
	
func notify(name: String, value):
	send( ECSEvent.new(name, value) )
	
func send(e: ECSEvent):
	e._event_center = weakref(self)
	_get_event_listener(e.name).receive(e)
	
func clear():
	_event_dict.clear()
	
func _get_event_listener(name: String) -> _listener:
	if not _event_dict.has(name):
		_event_dict[name] = _listener.new()
	return _event_dict[name]
	
# implement listener
class _listener extends RefCounted:
	signal _impl(e: ECSEvent)
	func add(c: Callable) -> bool:
		if _impl.is_connected(c):
			return false
		_impl.connect(c)
		return true
	func remove(c: Callable) -> bool:
		if not _impl.is_connected(c):
			return false
		_impl.disconnect(c)
		return true
	func receive(e: ECSEvent):
		_impl.emit(e)
	
