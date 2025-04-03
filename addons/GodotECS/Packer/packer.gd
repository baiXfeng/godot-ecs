extends RefCounted
class_name ECSWorldPacker

# ==============================================================================
# public
signal on_packed(sender: ECSWorldPacker, pack: ECSWorldPack)
signal on_unpacked(sender: ECSWorldPacker, pack: ECSWorldPack)

func pack_world() -> ECSWorldPack:
	var dict := {
		"version": _w.VERSION,
	}
	var pack := ECSWorldPack.new(dict)
	_load_uid_cache()
	_pack_world(dict)
	_pack_entities(dict)
	_on_packed(pack)
	return pack
	
func unpack_world(pack: ECSWorldPack) -> bool:
	var dict := pack.data()
	if _unpack_entities(dict):
		_unpack_world(dict)
		_on_unpacked(pack)
		return true
	return false
	
func test_component() -> void:
	for key: String in _w.get_component_keys():
		for c: ECSComponent in _w.view(key):
			c.test()
			break
	
# ==============================================================================
# private
var _w: ECSWorld
var _uid_cache: Dictionary
	
func _init(w: ECSWorld) -> void:
	_w = w
	
func _on_packed(pack: ECSWorldPack) -> void:
	on_packed.emit(self, pack)
	
func _on_unpacked(pack: ECSWorldPack) -> void:
	on_unpacked.emit(self, pack)
	
func _load_uid_cache() -> void:
	_uid_cache.clear()
	
	var f := FileAccess.open("res://.godot/uid_cache.bin", FileAccess.READ)
	if f == null:
		return
	
	var size := f.get_32()
	for i in size:
		var key := f.get_64()
		var length := f.get_32()
		var path := f.get_buffer(length).get_string_from_utf8()
		_uid_cache[path] = ResourceUID.id_to_text(key)
	
const CLASS = preload("../Serialization/serialize.gd")
	
func _pack_entities(dict: Dictionary) -> void:
	var entity_data := {}
	var class_list: Array[String]
	var uid_list: Array[String]
	for eid: int in _w.get_entity_keys():
		var e := _w.get_entity(eid)
		var entity_dict := {
			"components": {},
			"groups": e.get_groups(),
		}
		_pack_components(e, entity_dict["components"], class_list, uid_list)
		entity_data[eid] = entity_dict
	dict["entities"] = entity_data
	dict["class_list"] = uid_list
	dict["last_entity_id"] = _w._entity_id
	
func _pack_components(e: ECSEntity, dict: Dictionary, class_list: Array[String], uid_list: Array[String]) -> void:
	for c: ECSComponent in e.get_components():
		var c_dict := {}
		var output := CLASS.OutputArchive.new(c_dict)
		c.pack(output)
		dict[c.name()] = c_dict
		
		var res: Resource = c.get_script()
		var pos = class_list.find(res.resource_path)
		if pos == -1:
			class_list.append(res.resource_path)
			uid_list.append(_get_uid(res.resource_path))
			pos = class_list.size() - 1
		c_dict["_class_index"] = pos
	
func _get_uid(path: String) -> String:
	if _uid_cache.has(path):
		return _uid_cache[path]
	return path
	
func _unpack_entities(dict: Dictionary) -> bool:
	# verify version
	if not dict.has("version") or not _valid_version(dict["version"]):
		return false
	
	# verify keys
	var required_keys := ["entities", "class_list", "last_entity_id"]
	for key: String in required_keys:
		if not dict.has(key):
			return false
	
	_w.remove_all_entities()
	
	var class_list: Array[String] = dict.class_list
	
	# restore entities
	for eid: int in dict.entities:
		var entity_dict: Dictionary = dict.entities[eid]
		var e = _w._create_entity(eid)
		for name: String in entity_dict["groups"]:
			e.add_to_group(name)
	
	# restore components
	for eid: int in dict.entities:
		var entity_dict: Dictionary = dict.entities[eid]
		_unpack_components(_w.get_entity(eid), entity_dict["components"], class_list)
	
	# restore components data
	for eid: int in dict.entities:
		var entity_dict: Dictionary = dict.entities[eid]
		_unpack_archives(_w.get_entity(eid), entity_dict["components"])
	
	_w._entity_id = dict["last_entity_id"]
	
	return true
	
func _valid_version(version: String) -> bool:
	return true
	
func _unpack_components(e: ECSEntity, dict: Dictionary, class_list: Array[String]) -> void:
	# restore components
	for name: String in dict:
		
		# get class index
		var c_dict: Dictionary = dict[name]
		var index: int = c_dict["_class_index"]
		assert(index < class_list.size(), "unpack component fail: class index <%d> is invalid!" % index)
		
		# get class resource
		var CompScript: Resource = load(class_list[index])
		assert(CompScript != null, "unpack component fail: script <%s> is not exist!" % class_list[index])
		
		# create component
		var c: ECSComponent = CompScript.new()
		e.add_component(name, c)
	
func _unpack_archives(e: ECSEntity, dict: Dictionary) -> void:
	# load components archive
	for name: String in dict:
		var c_dict: Dictionary = dict[name]
		var c: ECSComponent = e.get_component(name)
		var input := CLASS.InputArchive.new(c_dict)
		_load_component_archive(c, input)
	
func _load_component_archive(c: ECSComponent, from: CLASS.Archive) -> void:
	# get newest version
	var ar := CLASS.InOutArchive.new({})
	c.pack(ar)
	var newest_version: int = ar.version
	
	# data upgrade
	ar.copy_from(from)
	while ar.version < newest_version:
		c.convert(ar)
		ar.version += 1
		
	# load the newest data
	c.unpack(ar)
	
# ==============================================================================
# override
func _pack_world(dict: Dictionary) -> void:
	pass
	
# override
func _unpack_world(dict: Dictionary) -> void:
	pass
	
