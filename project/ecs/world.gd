extends RefCounted
class_name ecs_world

var debug_print: bool

var _name: String

var _entity_id: int
var _entity_pool: Dictionary
var _system_pool: Dictionary
var _command_pool: Dictionary
var _event_pool: ecs_event_center = ecs_event_center.new()

var _type_component_dict: Dictionary
var _entity_component_dict: Dictionary
	
func _init(name: String = "ecs_world"):
	_name = name
	
func name() -> String:
	return _name
	
func clear():
	remove_all_systems()
	remove_all_commands()
	remove_all_entities()
	
func create_entity() -> ecs_entity:
	_entity_id += 1
	var e = ecs_entity.new(_entity_id, self)
	_entity_pool[_entity_id] = e
	_entity_component_dict[_entity_id] = {}
	if debug_print:
		print("entity <%s:%d> created." % [_name, _entity_id])
	return e
	
func remove_entity(entity_id: int) -> bool:
	if not remove_all_components(entity_id):
		return false
	if debug_print:
		print("entity <%s:%d> destroyed." % [_name, _entity_id])
	_entity_component_dict.erase(entity_id)
	return _entity_pool.erase(entity_id)
	
func remove_all_entities() -> bool:
	var keys = _entity_pool.keys()
	for entity_id in keys:
		remove_entity(entity_id)
	return true
	
func get_entity(id: int) -> ecs_entity:
	if has_entity(id):
		return _entity_pool[id]
	return null
	
func get_entity_keys() -> Array:
	var ret = []
	for key in _entity_pool:
		ret.append(key)
	return []
	
func has_entity(id: int) -> bool:
	return _entity_pool.has(id)
	
func add_component(entity_id: int, name: String, component) -> bool:
	if not has_entity(entity_id):
		return false
	var entity_dict = _entity_component_dict[entity_id]
	var type_list = _get_type_list(name)
	entity_dict[name] = component
	type_list[component] = true
	component._name = name
	component._entity = get_entity(entity_id)
	component._set_world(self)
	if debug_print:
		print("component <%s:%s> add to entity <%d>." % [_name, name, entity_id])
	notify("on_component_added", component)
	return true
	
func remove_component(entity_id: int, name: String) -> bool:
	if not has_entity(entity_id):
		return false
	var entity_dict = _entity_component_dict[entity_id]
	var type_list = _type_component_dict[name]
	var c = entity_dict[name]
	type_list.erase(c)
	if debug_print:
		print("component <%s:%s> remove from entity <%d>." % [_name, name, entity_id])
	notify("on_component_removed", c)
	return entity_dict.erase(name)
	
func remove_all_components(entity_id: int) -> bool:
	if not has_entity(entity_id):
		return false
	var entity_dict = _entity_component_dict[entity_id]
	for key in entity_dict.keys():
		remove_component(entity_id, key)
	return true
	
func get_component(entity_id: int, name: String):
	if not has_entity(entity_id):
		return null
	var entity_dict = _entity_component_dict[entity_id]
	if entity_dict.has(name):
		return entity_dict[name]
	return null
	
func get_components(entity_id: int) -> Array:
	if not has_entity(entity_id):
		return []
	var entity_dict = _entity_component_dict[entity_id]
	var ret = []
	for key in entity_dict:
		ret.append(entity_dict[key])
	return ret
	
func has_component(entity_id: int, name: String) -> bool:
	if not has_entity(entity_id):
		return false
	var entity_dict = _entity_component_dict[entity_id]
	return entity_dict.has(name)
	
func fetch_components(name: String) -> Array:
	if not _type_component_dict.has(name):
		return []
	var ret = []
	var list = _type_component_dict[name]
	for c in list:
		ret.append(c)
	return ret
	
func add_system(name: String, system) -> bool:
	remove_system(name)
	_system_pool[name] = system
	system._name = name
	system._set_world(self)
	system.on_enter(self)
	return true
	
func remove_system(name: String) -> bool:
	if not _system_pool.has(name):
		return false
	_system_pool[name].on_exit(self)
	return _system_pool.erase(name)
	
func remove_all_systems() -> bool:
	var keys = _system_pool.keys()
	for name in keys:
		remove_system(name)
	return true
	
func get_system(name: String):
	if not _system_pool.has(name):
		return null
	return _system_pool[name]
	
func get_system_keys() -> Array:
	return _system_pool.keys()
	
func has_system(name: String) -> bool:
	return _system_pool.has(name)
	
class _command_shell extends RefCounted:
	var _debug_print: bool
	var _class: Resource
	var _w_name: String
	func _init(r: Resource, debug_print: bool = false):
		_class = r
		_debug_print = debug_print
	func _register(w: ecs_world, name: String):
		_w_name = w.name()
		w.add_listener(name, self, "_on_event")
	func _unregister(w: ecs_world, name: String):
		w.remove_listener(name, self)
	func _on_event(e: ecs_event):
		if _debug_print:
			print("command <%s:%s> execute." % [_w_name, e.name])
		_class.new().execute(e)
	
func add_command(name: String, cmdres: Resource) -> bool:
	if cmdres == null:
		print("add command <%s:%s> fail: Resource is null." % [_name, name])
		return false
	remove_command(name)
	var shell = _command_shell.new(cmdres, debug_print)
	_command_pool[name] = shell
	shell._register(self, name)
	if debug_print:
		print("command <%s:%s> add to ecs_world." % [_name, name])
	return true
	
func remove_command(name: String) -> bool:
	if _command_pool.has(name):
		var shell = _command_pool[name]
		shell._unregister(self, name)
		if debug_print:
			print("command <%s:%s> remove from ecs_world." % [_name, name])
	return _command_pool.erase(name)
	
func remove_all_commands() -> bool:
	var keys = _command_pool.keys()
	for name in keys:
		remove_command(name)
	return true
	
func has_command(name: String):
	return _command_pool.has(name)
	
func add_listener(name: String, listener: Object, function: String):
	_event_pool.add(name, listener, function)
	
func remove_listener(name: String, listener: Object):
	_event_pool.remove(name, listener)
	
func notify(event_name: String, value = null):
	_event_pool.notify(event_name, value, self)
	
func send(e: ecs_event):
	_event_pool.send(e)
	
func _get_type_list(name: String) -> Dictionary:
	if not _type_component_dict.has(name):
		_type_component_dict[name] = {}
	return _type_component_dict[name]
	
