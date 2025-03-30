extends RefCounted
class_name ECSWorld

const VERSION = "2.1.0"

var debug_print: bool		# ecs logging
var debug_entity: bool		# for entity debugging
var ignore_notify_log: Dictionary # ignore notify log

signal on_system_viewed(name: String, components: Array)

var _name: String

var _entity_id: int = 0xFFFFFFFF
var _entity_pool: Dictionary
var _system_pool: Dictionary
var _command_pool: Dictionary
var _event_pool := ECSEventCenter.new()

var _type_component_dict: Dictionary
var _entity_component_dict: Dictionary
	
func _init(name := "ECSWorld") -> void:
	_name = name
	
func name() -> String:
	return _name
	
func clear() -> void:
	remove_all_systems()
	remove_all_commands()
	remove_all_entities()
	
# user valid entity id (0x1 ~ 0xFFFFFFFF)
func create_entity(id: int = 0) -> ECSEntity:
	assert(id >= 0 and id <= 0xFFFFFFFF, "create_entity invalid id!")
	var eid: int = id if id >= 1 else _entity_id + 1
	if id == 0:
		_entity_id += 1
	remove_entity(eid)
	return _create_entity(eid)
	
func remove_entity(entity_id: int) -> bool:
	if not remove_all_components(entity_id):
		return false
	for group_name: String in entity_get_groups(entity_id):
		entity_remove_from_group(entity_id, group_name)
	if debug_print:
		print("entity <%s:%d> destroyed." % [_name, entity_id])
	_entity_component_dict.erase(entity_id)
	return _entity_pool.erase(entity_id)
	
func remove_all_entities() -> bool:
	for entity_id: int in _entity_pool.keys():
		remove_entity(entity_id)
	_entity_id = 0xFFFFFFFF
	return true
	
func get_entity(id: int) -> ECSEntity:
	if has_entity(id):
		return _entity_pool[id]
	return null
	
func get_entity_keys() -> Array:
	return _entity_pool.keys()
	
func has_entity(id: int) -> bool:
	return _entity_pool.has(id)
	
func add_component(entity_id: int, name: String, component := ECSComponent.new()) -> bool:
	if not _add_entity_component(entity_id, name, component):
		return false
	component._name = name
	component._entity = get_entity(entity_id)
	component._set_world(self)
	if debug_print:
		print("component <%s:%s> add to entity <%d>." % [_name, name, entity_id])
	# 实体组件添加信号
	var entity: ECSEntity = component._entity
	entity.on_component_added.emit(entity, component)
	return true
	
func remove_component(entity_id: int, name: String) -> bool:
	var c: ECSComponent = get_component(entity_id, name)
	if not c or not _remove_entity_component(entity_id, name):
		return false
	if debug_print:
		print("component <%s:%s> remove from entity <%d>." % [_name, name, entity_id])
	# 实体组件移除信号
	var entity: ECSEntity = c._entity
	entity.on_component_removed.emit(entity, c)
	return true
	
func remove_all_components(entity_id: int) -> bool:
	if not has_entity(entity_id):
		return false
	var entity_dict: Dictionary = _entity_component_dict[entity_id]
	for key: String in entity_dict.keys():
		remove_component(entity_id, key)
	return true
	
func get_component(entity_id: int, name: String) -> ECSComponent:
	if not has_entity(entity_id):
		return null
	var entity_dict: Dictionary = _entity_component_dict[entity_id]
	if entity_dict.has(name):
		return entity_dict[name]
	return null
	
func get_components(entity_id: int) -> Array:
	if not has_entity(entity_id):
		return []
	var entity_dict: Dictionary = _entity_component_dict[entity_id]
	return entity_dict.values()
	
func get_component_keys() -> Array:
	return _type_component_dict.keys()
	
func has_component(entity_id: int, name: String) -> bool:
	if not has_entity(entity_id):
		return false
	var entity_dict: Dictionary = _entity_component_dict[entity_id]
	return entity_dict.has(name)
	
func view(name: String, filter := Callable()) -> Array:
	if not _type_component_dict.has(name):
		return []
	if not filter.is_valid():
		return _type_component_dict[name].values()
	var ret: Array = []
	for c: ECSComponent in _type_component_dict[name].values() as Array:
		if filter.call(c):
			ret.append(c)
	return ret
	
func multi_view(names: Array, filter := Callable()) -> Array:
	var result: Array = []
	for c: ECSComponent in view(names.front()):
		var e: ECSEntity = c.entity()
		if _is_satisfy_components(e, names):
			var dict: Dictionary = _get_satisfy_components(e, names)
			if filter.is_valid():
				if filter.call(dict):
					result.append(dict)
			else:
				result.append(dict)
	return result
	
var _group_entity_dict: Dictionary
var _entity_groups: Dictionary
	
func entity_add_to_group(entity_id: int, group_name: String) -> bool:
	if not has_entity(entity_id):
		return false
	var group_entity_dict: Dictionary = _get_group_entity_dict(group_name)
	group_entity_dict[ get_entity(entity_id) ] = true
	var entity_groups_dict: Dictionary = _get_entity_groups(entity_id)
	entity_groups_dict[ group_name ] = true
	if debug_print:
		print("entity <%s:%d> add to group <%s>." % [_name, entity_id, group_name])
	return true
	
func entity_remove_from_group(entity_id: int, group_name: String) -> bool:
	if not has_entity(entity_id):
		return false
	var group_entity_dict: Dictionary = _get_group_entity_dict(group_name)
	group_entity_dict.erase( get_entity(entity_id) )
	var entity_groups_dict: Dictionary = _get_entity_groups(entity_id)
	entity_groups_dict.erase( group_name )
	if debug_print:
		print("entity <%s:%d> remove from group <%s>." % [_name, entity_id, group_name])
	return true
	
func entity_get_groups(entity_id: int) -> Array:
	if not has_entity(entity_id):
		return []
	return _get_entity_groups(entity_id).keys()
	
func _get_group_entity_dict(group_name: String) -> Dictionary:
	if not _group_entity_dict.has(group_name):
		_group_entity_dict[group_name] = {}
	return _group_entity_dict[group_name]
	
func _get_entity_groups(entity_id: int) -> Dictionary:
	if not _entity_groups.has(entity_id):
		_entity_groups[entity_id] = {}
	return _entity_groups[entity_id]
	
func fetch_entities(group_name: String) -> Array:
	if _group_entity_dict.has(group_name):
		return _group_entity_dict[group_name].keys()
	return []
	
func group(group_name: String) -> Array:
	return fetch_entities(group_name)
	
func add_system(name: String, system: ECSSystem) -> bool:
	remove_system(name)
	_system_pool[name] = system
	system._set_name(name)
	system._set_world(self)
	system.on_enter(self)
	return true
	
func remove_system(name: String) -> bool:
	if not _system_pool.has(name):
		return false
	_system_pool[name].on_exit(self)
	return _system_pool.erase(name)
	
func remove_all_systems() -> bool:
	for name: String in _system_pool.keys():
		remove_system(name)
	return true
	
func get_system(name: String) -> ECSSystem:
	if not _system_pool.has(name):
		return null
	return _system_pool[name]
	
func get_system_keys() -> Array:
	return _system_pool.keys()
	
func has_system(name: String) -> bool:
	return _system_pool.has(name)
	
class _command_shell extends RefCounted:
	var _debug_print: bool
	var _class: GDScript
	var _c_name: StringName
	var _w_name: StringName
	var _world: WeakRef
	func _init(name: StringName, script: GDScript, debug_print := false) -> void:
		_c_name = name
		_class = script
		_debug_print = debug_print
	func _register(w: ECSWorld, name: String) -> void:
		_w_name = w.name()
		_world = weakref(w)
		w.add_callable(name, _on_event)
	func _unregister(w: ECSWorld, name: String) -> void:
		w.remove_callable(name, _on_event)
		_world = null
	func _on_event(e: ECSEvent) -> void:
		if _debug_print:
			print("command <%s:%s> execute." % [_w_name, e.name])
		var cmd: ECSCommand = _class.new()
		cmd._set_world(_world.get_ref())
		cmd._set_name(_c_name)
		cmd.execute(e)
	
func add_command(name: String, cmd_script: GDScript) -> bool:
	if cmd_script == null:
		print("add command <%s:%s> fail: GDScript is null." % [_name, name])
		return false
	remove_command(name)
	var shell := _command_shell.new(name, cmd_script, debug_print)
	_command_pool[name] = shell
	shell._register(self, name)
	if debug_print:
		print("command <%s:%s> add to ECSWorld." % [_name, name])
	return true
	
func remove_command(name: String) -> bool:
	if _command_pool.has(name):
		var shell: _command_shell = _command_pool[name]
		shell._unregister(self, name)
		if debug_print:
			print("command <%s:%s> remove from ECSWorld." % [_name, name])
	return _command_pool.erase(name)
	
func remove_all_commands() -> bool:
	for name: String in _command_pool.keys():
		remove_command(name)
	return true
	
func has_command(name: String) -> bool:
	return _command_pool.has(name)
	
func add_callable(name: String, c: Callable) -> void:
	_event_pool.add_callable(name, c)
	
func remove_callable(name: String, c: Callable) -> void:
	_event_pool.remove_callable(name, c)
	
func notify(event_name: String, value = null) -> void:
	if debug_print and not ignore_notify_log.has(event_name):
		print('notify <%s> "%s", %s.' % [_name, event_name, value])
	_event_pool.notify(event_name, value)
	
func send(e: ECSEvent) -> void:
	if debug_print and not ignore_notify_log.has(e.name):
		print('send <%s> "%s", %s.' % [_name, e.name, e.data])
	_event_pool.send(e)
	
func _get_type_list(name: String) -> Dictionary:
	if not _type_component_dict.has(name):
		_type_component_dict[name] = {}
	return _type_component_dict[name]
	
func _is_satisfy_components(e: ECSEntity, names: Array) -> bool:
	for key: String in names:
		if not has_component(e.id(), key):
			return false
	return true
	
func _get_satisfy_components(e: ECSEntity, names: Array) -> Dictionary:
	var result := {}
	for key: String in names:
		result[key] = get_component(e.id(), key)
	return result
	
func _add_entity_component(entity_id: int, name: String, component: ECSComponent) -> bool:
	if not has_entity(entity_id):
		return false
	var entity_dict: Dictionary = _entity_component_dict[entity_id]
	entity_dict[name] = component
	var type_list: Dictionary = _get_type_list(name)
	type_list[entity_id] = component
	return true
	
func _remove_entity_component(entity_id: int, name: String) -> bool:
	if not has_entity(entity_id):
		return false
	var type_list: Dictionary = _type_component_dict[name]
	type_list.erase(entity_id)
	var entity_dict: Dictionary = _entity_component_dict[entity_id]
	return entity_dict.erase(name)
	
func _create_entity(eid: int) -> ECSEntity:
	var e := ECSEntity.new(eid, self) if not debug_entity else DebugEntity.new(eid, self)
	_entity_pool[eid] = e
	_entity_component_dict[eid] = {}
	if debug_print:
		print("entity <%s:%d> created." % [_name, eid])
	return e
	
