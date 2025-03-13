extends RefCounted
class_name ECSCommand

var _cmd_list: Array[ECSCommand]
var _world: WeakRef

func add_command(cmd: ECSCommand) -> void:
	_cmd_list.append(cmd)
	
func execute(e: ECSEvent) -> void:
	for cmd: ECSCommand in _cmd_list:
		cmd._set_world(world())
		cmd.execute(e)
	_on_execute(e)
	
func world() -> ECSWorld:
	return _world.get_ref()
	
func view(name: String) -> Array[ECSComponent]:
	return world().view(name)
	
func multi_view(names: Array[String]) -> Array[Dictionary]:
	return world().multi_view(names)
	
func group(name: String) -> Array[ECSEntity]:
	return world().group(name)
	
# ==============================================================================
# override
func _on_execute(e: ECSEvent) -> void:
	pass
	
func _set_world(w: ECSWorld) -> void:
	_world = weakref(w)
	
