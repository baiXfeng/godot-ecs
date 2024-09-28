extends RefCounted
class_name ecs_command

var _cmd_list: Array
var _world: WeakRef

func add_command(cmd):
	_cmd_list.append(cmd)
	
func execute(e: ecs_event):
	for cmd in _cmd_list:
		cmd._set_world(world())
		cmd.execute(e)
	_on_execute(e)
	
func world() -> ecs_world:
	return _world.get_ref()
	
func view(name: String) -> Array:
	return world().view(name)
	
func multi_view(names: Array[String]) -> Array:
	return world().multi_view(names)
	
func group(name: String) -> Array:
	return world().group(name)
	
# ==============================================================================
# override
func _on_execute(e: ecs_event):
	pass
	
func _set_world(w: ecs_world):
	_world = weakref(w)
	
