extends RefCounted
class_name ECSComponent

const Serialization = preload("Serialization/header.gd")
const Archive = Serialization.Archive
const InputArchive = Serialization.InputArchive
const OutputArchive = Serialization.OutputArchive

var _name: String
var _entity: ECSEntity
var _world: WeakRef

func name() -> String:
	return _name
	
func entity() -> ECSEntity:
	return _entity
	
func world() -> ECSWorld:
	return _world.get_ref()
	
func save(ar: Archive) -> void:
	_on_save(ar)
	
func load(ar: Archive) -> void:
	_on_load(ar)
	
func convert(ar: Archive) -> void:
	_on_convert(ar)
	
func test() -> void:
	_on_test()
	
func _set_world(world: ECSWorld) -> void:
	_world = weakref(world)
	
func _to_string() -> String:
	return "component:%s" % _name
	
# override
func _on_save(ar: Archive) -> void:
	pass
	
# override
func _on_load(ar: Archive) -> void:
	pass
	
# override
func _on_convert(ar: Archive) -> void:
	pass
	
# override
func _on_test() -> void:
	pass
	
