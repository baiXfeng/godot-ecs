extends RefCounted
class_name ECSComponent

var _name: String
var _entity: ECSEntity
var _world: WeakRef

func name() -> String:
	return _name
	
func entity() -> ECSEntity:
	return _entity
	
func world() -> ECSWorld:
	return _world.get_ref()
	
func _set_world(world: ECSWorld) -> void:
	_world = weakref(world)
	
func _to_string() -> String:
	return "component:%s" % _name
	
func save(dict: Dictionary) -> void:
	_on_save(dict)
	
func load(dict: Dictionary) -> void:
	_on_load(dict)
	
# override
func _on_save(dict: Dictionary) -> void:
	pass
	
# override
func _on_load(dict: Dictionary) -> void:
	pass
	
