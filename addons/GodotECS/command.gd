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
	
func group_view(group_name: String, name: String, filter := Callable()) -> Array:
	var w := world()
	w.on_system_viewed.emit(_name, [name])
	return w.group_view(group_name, name, filter)
	
func group_multi_view(group_name: String, names: Array[String], filter := Callable()) -> Array:
	var w := world()
	w.on_system_viewed.emit(_name, names)
	return w.group_multi_view(group_name, names, filter)
	
func notify(event_name: String, value = null) -> void:
	world().notify(event_name, value)
	
func send(e: ECSEvent) -> void:
	world().send(e)
	
# ==============================================================================
# override
func _on_execute(e: ECSEvent) -> void:
	pass
	
func _set_world(w: ECSWorld) -> void:
	_world = weakref(w)
	
func _set_name(name: StringName) -> void:
	_name = name
	
