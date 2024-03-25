extends RefCounted
class_name ecs_entity

var _id: int
var _world: WeakRef

func _init(id: int, world):
	_id = id
	_world = weakref(world)
	
func destroy():
	world().remove_entity(_id)
	
func id() -> int:
	return _id
	
func world():
	return _world.get_ref()
	
func valid() -> bool:
	return world().has_entity(_id)
	
func add_component(name: String, component) -> bool:
	return world().add_component(_id, name, component)
	
func remove_component(name: String) -> bool:
	return world().remove_component(_id, name)
	
func remove_all_components() -> bool:
	return world().remove_all_components()
	
func get_component(name: String):
	return world().get_component(_id, name)
	
func get_components() -> Array:
	return world().get_components(_id)
	
func has_component(name: String) -> bool:
	return world().has_component(_id, name)
	
func _to_string() -> String:
	return "entity:%d" % _id
	
