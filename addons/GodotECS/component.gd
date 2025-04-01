extends "Serialization/serialize.gd"
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
	
# override
func _on_pack(ar: Archive) -> void:
	pass
	
# override
func _on_unpack(ar: Archive) -> void:
	pass
	
# override
func _on_convert(ar: Archive) -> void:
	pass
	
# override
func _on_test() -> void:
	pass
	
