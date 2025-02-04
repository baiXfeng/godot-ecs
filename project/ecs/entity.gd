extends RefCounted
class_name ECSEntity

var _id: int
var _world: WeakRef

signal on_component_added(entity, component)
signal on_component_removed(entity, component)

func _init(id: int, world):
	_id = id
	_world = weakref(world)
	
func destroy():
	if _id != 0:
		world().remove_entity(_id)
		_id = 0
	
func id() -> int:
	return _id
	
func world() -> ECSWorld:
	return _world.get_ref()
	
func valid() -> bool:
	return _id >= 1 and world().has_entity(_id)
	
func notify(event_name: String, value = null):
	if _id == 0:
		return
	world().notify(event_name, value)
	
func send(e: ECSEvent):
	if _id == 0:
		return
	world().send(e)
	
func add_component(name: String, component = ECSComponent.new()) -> bool:
	return world().add_component(_id, name, component)
	
func remove_component(name: String) -> bool:
	return world().remove_component(_id, name)
	
func remove_all_components() -> bool:
	return world().remove_all_components(_id)
	
func get_component(name: String):
	return world().get_component(_id, name)
	
func get_components() -> Array:
	return world().get_components(_id)
	
func has_component(name: String) -> bool:
	return world().has_component(_id, name)
	
func add_to_group(group_name: String) -> bool:
	return world().entity_add_to_group(_id, group_name)
	
func remove_from_group(group_name: String) -> bool:
	return world().entity_remove_from_group(_id, group_name)
	
func get_groups() -> Array:
	return world().entity_get_groups(_id)
	
func _to_string() -> String:
	return "entity:%d" % _id
	
