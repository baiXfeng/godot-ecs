extends Reference
class_name ecs_world

var debug_print: bool

var _entity_id: int
var _entity_pool: Dictionary
var _system_pool: Dictionary
var _event_pool: ecs_event = ecs_event.new()

var _type_component_dict: Dictionary
var _entity_component_dict: Dictionary

func clear():
	remove_all_systems()
	remove_all_entities()
	
func create_entity() -> ecs_entity:
	_entity_id += 1
	var e = ecs_entity.new(_entity_id, self)
	_entity_pool[_entity_id] = e
	_entity_component_dict[_entity_id] = {}
	if debug_print:
		print("entity <%d> created." % _entity_id)
	return e
	
func remove_entity(entity_id: int) -> bool:
	if not remove_all_components(entity_id):
		return false
	if debug_print:
		print("entity <%d> destroyed." % _entity_id)
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
	component._entity_id = entity_id
	component._entity = get_entity(entity_id)
	component._set_world(self)
	if debug_print:
		print("component <%s> add to entity <%d>." % [name, entity_id])
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
		print("component <%s> remove from entity <%d>." % [name, entity_id])
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
	system._debug_print = debug_print
	system._name = name
	system._set_world(self)
	system._register_event(_event_pool)
	system.on_enter()
	return true
	
func remove_system(name: String) -> bool:
	if not _system_pool.has(name):
		return false
	_system_pool[name].on_exit()
	_system_pool[name]._unregister_event(_event_pool)
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
	
func on_process(name: String, delta: float):
	_system_pool[name].on_process(delta)
	
func on_physics_process(name: String, delta: float):
	_system_pool[name].on_physics_process(delta)
	
func notify(event_name: String, param = null):
	_event_pool.fetch_listener(funcref(self, "_on_system_on_event"), event_name, param)
	
func _get_type_list(name: String) -> Dictionary:
	if not _type_component_dict.has(name):
		_type_component_dict[name] = {}
	return _type_component_dict[name]
	
func _on_system_on_event(system, name, param):
	system.on_event(name, param)
	
