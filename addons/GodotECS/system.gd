extends RefCounted
class_name ECSSystem

var _name: String
var _world: WeakRef

func name() -> String:
	return _name
	
func world() -> ECSWorld:
	return _world.get_ref()
	
func view(name: String, filter := Callable()) -> Array:
	return world().view(name, filter)
	
func multi_view(names: Array, filter := Callable()) -> Array:
	return world().multi_view(names, filter)
	
func group(name: String) -> Array:
	return world().group(name)
	
func on_enter(w: ECSWorld) -> void:
	if w.debug_print:
		print("system <%s:%s> on_enter." % [world().name(), _name])
	_on_enter(w)
	
func on_exit(w: ECSWorld) -> void:
	if w.debug_print:
		print("system <%s:%s> on_exit." % [world().name(), _name])
	_on_exit(w)
	
func notify(event_name: String, value = null) -> void:
	world().notify(event_name, value)
	
func send(e: ECSEvent) -> void:
	world().send(e)
	
# ==============================================================================
# override function
	
# override
func _on_enter(w: ECSWorld) -> void:
	pass
	
# override
func _on_exit(w: ECSWorld) -> void:
	pass
	
# ==============================================================================
# private function
	
func _set_name(n: String) -> void:
	_name = n
	
func _set_world(w: ECSWorld) -> void:
	_world = weakref(w)
	
func _to_string() -> String:
	return "system:%s" % _name
	
