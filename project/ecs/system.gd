extends Reference
class_name ecs_system

var _name: String
var _world: WeakRef
var _debug_print: bool

func name() -> String:
	return _name
	
func world() -> ecs_world:
	return _world.get_ref()
	
func save(dict: Dictionary):
	_on_save(dict)
	
func load(dict: Dictionary):
	_on_load(dict)
	
func on_enter():
	if _debug_print:
		print("system<%s> on_enter." % _name)
	_on_enter()
	
func on_exit():
	if _debug_print:
		print("system<%s> on_exit." % _name)
	_on_exit()
	
func on_process(delta: float):
	_on_process(delta)
	
func on_physics_process(delta: float):
	_on_physics_process(delta)
	
func on_event(name: String, param):
	if _debug_print:
		print("system<%s> on_event(%s, %s)." % [_name, name, param])
	_on_event(name, param)
	
# ==============================================================================
# private function
	
func _set_world(world: ecs_world):
	_world = weakref(world)
	
# override
func _list_events() -> Array:
	# return event name list for interested
	return []
	
func _register_event(e: ecs_event):
	var events = _list_events()
	for name in events:
		e.add_listener(name, self)
	
func _unregister_event(e: ecs_event):
	var events = _list_events()
	for name in events:
		e.remove_listener(name, self)
	
func _to_string() -> String:
	return "system:%s" % _name
	
# override
func _on_save(dict: Dictionary):
	pass
	
# override
func _on_load(dict: Dictionary):
	pass
	
# override
func _on_enter():
	pass
	
# override
func _on_exit():
	pass
	
# override
func _on_process(delta: float):
	if _debug_print:
		print("system<%s> on_process(%.3f)." % [_name, delta])
	
# override
func _on_physics_process(delta: float):
	if _debug_print:
		print("system<%s> on_physics_process(%.3f)." % [_name, delta])
	
# override
func _on_event(name: String, param):
	pass
	
