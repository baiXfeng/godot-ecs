extends DataPacker
class_name ECSWorldPacker

## A serializer for ECSWorld instances that handles complete world state
## including all entities, components, and component data.

# ==============================================================================
# Public API - Factory Configuration
# ==============================================================================

## Sets the object factory for component type resolution during serialization.
## Required for registering inner class components.
## @param f: The ObjectFactory instance to use.
## @return: This packer instance for method chaining.
func with_factory(f: ObjectFactory) -> ECSWorldPacker:
	_factory = f
	return self

## Returns the current object factory.
## @return: The ObjectFactory instance.
func factory() -> ObjectFactory:
	return _factory

# ==============================================================================
# Public API - Selective Serialization
# ==============================================================================

## Keeps only the specified entities in subsequent pack or merge-unpack operations.
## Calling this method with an empty array selects no entities.
func entities(ids: Array[int]) -> ECSWorldPacker:
	if not _use_uniform_selection():
		return self
	_selected_entities = ids.duplicate()
	_has_entity_selection = true
	return self

## Keeps only the specified component names in subsequent pack or merge-unpack operations.
## Calling this method with an empty array selects no components.
func components(names: Array[StringName]) -> ECSWorldPacker:
	if not _use_uniform_selection():
		return self
	_selected_components = names.duplicate()
	_has_component_selection = true
	return self

## Selects one entity and its components for subsequent pack or merge-unpack operations.
## An empty component list selects all components on that entity.
func include(entity_id: int, names: Array[StringName] = []) -> ECSWorldPacker:
	if _selection_mode == SELECTION_UNIFORM:
		push_error("Cannot combine include() with entities() or components().")
		_selection_mode = SELECTION_INVALID
		return self
	_selection_mode = SELECTION_INCLUDED
	_included_components[entity_id] = names.duplicate()
	return self

## Sets how merge unpacking handles a component that already exists on an entity.
func on_component_conflict(policy: int) -> ECSWorldPacker:
	if policy < SKIP or policy > REPLACE_COMPONENT:
		push_error("Invalid component conflict policy <%d>." % policy)
		return self
	_component_conflict_policy = policy
	return self

## Merges a DataPack into the current world without removing unrelated entities or components.
func unpack_merge(pack: DataPack) -> bool:
	if _selection_mode == SELECTION_INVALID:
		return false
	return _unpack_entities_merge(pack.data())

# ==============================================================================
# Override Methods - Serialization
# ==============================================================================

## Internal: Creates a DataPack containing the complete world state.
## @return: DataPack with entities, components, and metadata.
func _pack() -> DataPack:
	if _selection_mode == SELECTION_INVALID:
		return null
	var dict := {
		"version": _w.VERSION,
	}
	var pack := DataPack.new(dict)
	_pack_entities(dict)
	return pack

## Internal: Restores world state from a DataPack.
## @param pack: The DataPack containing serialized world state.
## @return: True if unpacking succeeded.
func _unpack(pack: DataPack) -> bool:
	return _unpack_entities(pack.data())

# ==============================================================================
# Private Members
# ==============================================================================

var _w: ECSWorld
var _filter: Array[StringName]
var _factory := ObjectFactory.new()

const SKIP := 0
const OVERWRITE_DATA := 1
const REPLACE_COMPONENT := 2

const SELECTION_NONE := 0
const SELECTION_UNIFORM := 1
const SELECTION_INCLUDED := 2
const SELECTION_INVALID := 3

var _selection_mode := SELECTION_NONE
var _selected_entities: Array[int] = []
var _selected_components: Array[StringName] = []
var _included_components: Dictionary
var _has_entity_selection := false
var _has_component_selection := false
var _component_conflict_policy := OVERWRITE_DATA

## Creates a new ECSWorldPacker for the specified world.
## @param w: The ECSWorld to serialize.
## @param filter: Legacy component query filter used when no explicit selection is configured.
func _init(w: ECSWorld, filter: Array[StringName] = []) -> void:
	_w = w
	_filter = filter

# ==============================================================================
# Private Methods - Packing
# ==============================================================================

## Internal: Packs all entities into the dictionary.
## @param dict: The dictionary to populate with entity data.
func _pack_entities(dict: Dictionary) -> void:
	var entity_data := {}
	var uid_list: Array[int]
	for eid: int in _selected_entity_ids_for_pack():
		var e := _w.get_entity(eid)
		if e == null:
			continue
		var entity_dict := {
			"components": {},
		}
		_pack_components(e, entity_dict["components"], uid_list, _selected_components_for_entity(eid), _has_component_filter_for_entity(eid))
		entity_data[e.id()] = entity_dict
	
	dict["entities"] = entity_data
	dict["uid_list"] = uid_list
	dict["last_entity_id"] = _w._entity_id

## Internal: Packs all components of an entity.
## @param e: The entity whose components to pack.
## @param dict: The dictionary to populate with component data.
## @param uid_list: The list to populate with component type UIDs.
func _pack_components(e: ECSEntity, dict: Dictionary, uid_list: Array[int], names: Array[StringName] = [], filter_components := false) -> void:
	var components: Array[ECSComponent] = []
	if not filter_components:
		components.assign(e.get_components())
	else:
		for name: StringName in names:
			var component := e.get_component(name)
			if component:
				components.append(component)
	for c: ECSComponent in components:
		var c_dict := {}
		var output := Serializer.OutputArchive.new(c_dict)
		c.pack(output)
		dict[c.name()] = c_dict
		
		var uid := _factory.object_to_uid(c)
		var pos = uid_list.find(uid)
		if pos == -1:
			uid_list.append(uid)
			pos = uid_list.size() - 1
		c_dict["_class_index"] = pos

# ==============================================================================
# Private Methods - Unpacking
# ==============================================================================

## Internal: Unpacks all entities from the dictionary.
## @param dict: The dictionary containing entity data.
## @return: True if unpacking succeeded.
func _unpack_entities(dict: Dictionary) -> bool:
	if not _validate_pack(dict, true):
		return false
	
	_w.remove_all_entities()
	
	var uid_list: Array[int] = dict.uid_list
	
	for eid: int in dict.entities:
		var entity_dict: Dictionary = dict.entities[eid]
		var e = _w._create_entity(eid)
	
	for eid: int in dict.entities:
		var entity_dict: Dictionary = dict.entities[eid]
		_unpack_components(_w.get_entity(eid), entity_dict["components"], uid_list)
	
	for eid: int in dict.entities:
		var entity_dict: Dictionary = dict.entities[eid]
		_unpack_archives(_w.get_entity(eid), entity_dict["components"])
	
	_w._entity_id = dict["last_entity_id"]
	
	return true

## Internal: Merges selected entities and components into the current world.
func _unpack_entities_merge(dict: Dictionary) -> bool:
	if not _validate_pack(dict, false):
		return false

	var uid_list: Array[int] = dict.uid_list
	var components_to_load := {}
	for eid: int in dict.entities:
		if not _is_entity_selected(eid):
			continue
		var entity_dict: Dictionary = dict.entities[eid]
		if not entity_dict.has("components"):
			push_error("unpack merge fail: entity <%d> has no components." % eid)
			return false
		var e: ECSEntity = _w.get_entity(eid)
		if e == null:
			e = _w._create_entity(eid)
			if _w._entity_id == 0xFFFFFFFF or eid > _w._entity_id:
				_w._entity_id = eid
		var names_to_load: Array[StringName] = []
		var component_dict: Dictionary = entity_dict["components"]
		for name: StringName in component_dict:
			if not _is_component_selected(eid, name):
				continue
			var current := e.get_component(name)
			if current and _component_conflict_policy == SKIP:
				continue
			if current and _component_conflict_policy == REPLACE_COMPONENT:
				e.remove_component(name)
				current = null
			if current == null:
				var component := _create_component(name, component_dict[name], uid_list)
				if component == null or not e.add_component(name, component):
					return false
			names_to_load.append(name)
		components_to_load[eid] = names_to_load

	for eid: int in components_to_load:
		var entity_dict: Dictionary = dict.entities[eid]
		var component_dict: Dictionary = entity_dict["components"]
		var e := _w.get_entity(eid)
		for name: StringName in components_to_load[eid]:
			var input := Serializer.InputArchive.new(component_dict[name])
			_load_component_archive(e.get_component(name), input)

	return true

## Internal: Validates the serialization version.
## @param version: The version string to validate.
## @return: True if version is compatible.
func _valid_version(version: StringName) -> bool:
	return true

## Internal: Validates the shared DataPack structure.
func _validate_pack(dict: Dictionary, require_last_entity_id: bool) -> bool:
	if not dict.has("version") or not _valid_version(dict["version"]):
		return false
	var required_keys := ["entities", "uid_list"]
	if require_last_entity_id:
		required_keys.append("last_entity_id")
	for key: StringName in required_keys:
		if not dict.has(key):
			return false
	return true

## Internal: Unpacks component instances from the dictionary.
## @param e: The entity to add components to.
## @param dict: The dictionary containing component data.
## @param uid_list: The list of component type UIDs.
func _unpack_components(e: ECSEntity, dict: Dictionary, uid_list: Array[int]) -> void:
	for name: StringName in dict:
		var c_dict: Dictionary = dict[name]
		var index: int = c_dict["_class_index"]
		
		if index >= uid_list.size():
			push_error("unpack component fail: class index <%d> is invalid!" % index)
			continue
		
		var uid := uid_list[index]
		var c: ECSComponent = _factory.uid_to_object(uid)
		if c:
			e.add_component(name, c)
		else:
			e.add_component(name)
			push_error("unpack component fail: script <%s> is not exist!" % ResourceUID.id_to_text(uid_list[index]))

## Internal: Creates a component instance described by packed component metadata.
func _create_component(name: StringName, component_dict: Dictionary, uid_list: Array[int]) -> ECSComponent:
	if not component_dict.has("_class_index"):
		push_error("unpack component fail: component <%s> has no class index." % name)
		return null
	var index: int = component_dict["_class_index"]
	if index < 0 or index >= uid_list.size():
		push_error("unpack component fail: class index <%d> is invalid!" % index)
		return null
	var component := _factory.uid_to_object(uid_list[index]) as ECSComponent
	if component == null:
		push_error("unpack component fail: script <%s> is not a component." % ResourceUID.id_to_text(uid_list[index]))
	return component

## Internal: Unpacks component data archives.
## @param e: The entity whose components to populate.
## @param dict: The dictionary containing component archive data.
func _unpack_archives(e: ECSEntity, dict: Dictionary) -> void:
	for name: StringName in dict:
		var c_dict: Dictionary = dict[name]
		var c: ECSComponent = e.get_component(name)
		var input := Serializer.InputArchive.new(c_dict)
		_load_component_archive(c, input)

## Internal: Loads component data with version migration support.
## @param c: The component to populate.
## @param from: The archive containing serialized data.
func _load_component_archive(c: ECSComponent, from: Serializer.Archive) -> void:
	var ar := Serializer.InOutArchive.new({})
	c.pack(ar)
	var newest_version: int = ar.version
	
	ar.copy_from(from)
	while ar.version < newest_version:
		c.convert(ar)
		ar.version += 1
		
	c.unpack(ar)

# ==============================================================================
# Private Methods - Selection
# ==============================================================================

## Internal: Switches to uniform selection unless per-entity selection is active.
func _use_uniform_selection() -> bool:
	if _selection_mode == SELECTION_INCLUDED:
		push_error("Cannot combine entities() or components() with include().")
		_selection_mode = SELECTION_INVALID
		return false
	if _selection_mode == SELECTION_INVALID:
		return false
	_selection_mode = SELECTION_UNIFORM
	return true

## Internal: Returns entity IDs selected for packing.
func _selected_entity_ids_for_pack() -> Array[int]:
	if _selection_mode == SELECTION_INCLUDED:
		var ids: Array[int] = []
		for eid: int in _included_components:
			ids.append(eid)
		return ids
	if _selection_mode == SELECTION_UNIFORM and _has_entity_selection:
		return _selected_entities
	if _selection_mode == SELECTION_NONE and not _filter.is_empty():
		var ids: Array[int] = []
		for views: Dictionary in _w.multi_view(_filter):
			ids.append(views.entity.id())
		return ids
	var ids: Array[int] = []
	for eid: int in _w.get_entity_keys():
		ids.append(eid)
	return ids

## Internal: Returns selected component names for one packed entity.
func _selected_components_for_entity(entity_id: int) -> Array[StringName]:
	if _selection_mode == SELECTION_INCLUDED:
		return _included_components[entity_id]
	if _selection_mode == SELECTION_UNIFORM and _has_component_selection:
		return _selected_components
	return []

## Internal: Checks whether packing should filter component names for one entity.
func _has_component_filter_for_entity(entity_id: int) -> bool:
	if _selection_mode == SELECTION_INCLUDED:
		var names: Array[StringName] = _included_components[entity_id]
		return not names.is_empty()
	return _selection_mode == SELECTION_UNIFORM and _has_component_selection

## Internal: Checks whether an entity is selected for merge unpacking.
func _is_entity_selected(entity_id: int) -> bool:
	if _selection_mode == SELECTION_INCLUDED:
		return _included_components.has(entity_id)
	if _selection_mode == SELECTION_UNIFORM and _has_entity_selection:
		return _selected_entities.has(entity_id)
	return true

## Internal: Checks whether a component is selected for merge unpacking.
func _is_component_selected(entity_id: int, name: StringName) -> bool:
	if _selection_mode == SELECTION_INCLUDED:
		var names: Array[StringName] = _included_components[entity_id]
		return names.is_empty() or names.has(name)
	if _selection_mode == SELECTION_UNIFORM and _has_component_selection:
		return _selected_components.has(name)
	return true
