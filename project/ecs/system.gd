extends RefCounted
class_name ecs_system

var _name: String
var _world: WeakRef

func name() -> String:
	return _name
	
func world() -> ecs_world:
	return _world.get_ref()
	
func save(dict: Dictionary):
	_on_save(dict)
	
func load(dict: Dictionary):
	_on_load(dict)
	
func on_enter(w: ecs_world):
	if w.debug_print:
		print("system <%s:%s> on_enter." % [world().name(), _name])
	_on_enter(w)
	
func on_exit(w: ecs_world):
	if w.debug_print:
		print("system <%s:%s> on_exit." % [world().name(), _name])
	_on_exit(w)
	
func notity(event_name: String, value = null):
	world().notity(event_name, value)
	
func send(e: ecs_event):
	world().send(e)
	
# ==============================================================================
# override function
	
# override
func _on_enter(w: ecs_world):
	pass
	
# override
func _on_exit(w: ecs_world):
	pass
	
# override
func _on_save(dict: Dictionary):
	pass
	
# override
func _on_load(dict: Dictionary):
	pass
	
# ==============================================================================
# private function
	
func _set_name(n: String):
	_name = n
	
func _set_world(w: ecs_world):
	_world = weakref(w)
	
func _to_string() -> String:
	return "system:%s" % _name
	
