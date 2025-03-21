extends RefCounted
class_name ECSCommand

var _cmd_list: Array
var _world: WeakRef
var _name: StringName

func add_command(cmd: ECSCommand) -> void:
	_cmd_list.append(cmd)
	
func execute(e: ECSEvent) -> void:
	for i in _cmd_list.size():
		var cmd: ECSCommand = _cmd_list[i]
		cmd._set_world(world())
		cmd._set_name("%s_%d" % [_name, i])
		cmd.execute(e)
	_on_execute(e)
	
func world() -> ECSWorld:
	return _world.get_ref()
	
func view(name: String, filter := Callable()) -> Array:
	var w := world()
	w.on_system_viewed.emit(_name, [name])
	return w.view(name, filter)
	
func multi_view(names: Array, filter := Callable()) -> Array:
	var w := world()
	w.on_system_viewed.emit(_name, names)
	return w.multi_view(names, filter)
	
func group(name: String) -> Array:
	return world().group(name)
	
# ==============================================================================
# override
func _on_execute(e: ECSEvent) -> void:
	pass
	
func _set_world(w: ECSWorld) -> void:
	_world = weakref(w)
	
func _set_name(name: StringName) -> void:
	_name = name
	
