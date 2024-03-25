extends Reference
class_name ecs_component

var _name: String
var _entity: ecs_entity
var _entity_id: int
var _world: WeakRef

func name() -> String:
	return _name
	
func entity() -> ecs_entity:
	return _entity
	
func entity_id() -> int:
	return _entity_id
	
func world() -> ecs_world:
	return _world.get_ref()
	
func _set_world(world: ecs_world):
	_world = weakref(world)
	
func _to_string() -> String:
	return "component:%s" % _name
	
func save(dict: Dictionary):
	dict["ecs_name"] = name()
	_on_save(dict)
	
func load(dict: Dictionary):
	_on_load(dict)
	
# override
func _on_save(dict: Dictionary):
	pass
	
# override
func _on_load(dict: Dictionary):
	pass
	
