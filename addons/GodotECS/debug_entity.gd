extends ECSEntity
class_name DebugEntity

# Member variables for debugging
var _components: Dictionary[StringName, ECSComponent]
var _groups: Dictionary[StringName, bool]

func add_component(name: String, component := ECSComponent.new()) -> bool:
	_components[name] = component
	return super.add_component(name, component)
	
func remove_component(name: String) -> bool:
	_components.erase(name)
	return super.remove_component(name)
	
func remove_all_components() -> bool:
	_components.clear()
	return super.remove_all_components()
	
func add_to_group(group_name: String) -> bool:
	_groups[group_name] = true
	return super.add_to_group(group_name)
	
func remove_from_group(group_name: String) -> bool:
	_groups.erase(group_name)
	return super.remove_from_group(group_name)
	
