extends RefCounted
class_name ECSTest

var _world := ECSWorld.new("ECSWorld_test")
var _entity: ECSEntity

func _init() -> void:
	_world.debug_print = true
	test_entity()
	test_component()
	test_system()
	test_remove_component()
	test_remove_entity()
	test_remove_system()
	mixed_test()
	test_snapshot()
	test_event()
	test_command()
	test_entity_add_to_group()
	
func queue_free() -> void:
	_entity = null
	_world.clear()
	
func test_entity() -> void:
	_entity = _world.create_entity()
	_entity.add_to_group("first_entity")
	_entity.add_to_group("test_group")
	
	var e: ECSEntity = _world.get_entity(_entity.id())
	printt("entity id is equality:", e.id() == _entity.id())
	
	var first_entity_group: Array = _world.group("first_entity")
	printt("first entity group:", first_entity_group.size(), first_entity_group.front().id())
	
	var test_entity_group: Array = _world.group("test_group")
	printt("test entity group:", test_entity_group.size(), test_entity_group.front().id())
	
	print("")
	
func test_component() -> void:
	_entity.add_component("c1", ECSComponent.new())
	_entity.add_component("c2", ECSComponent.new())
	_entity.add_component("c3", ECSComponent.new())
	_entity.add_component("c4", ECSDataComponent.new(11))
	_entity.add_component("c5", ECSViewComponent.new(null))
	print("")
	
func test_system() -> void:
	_world.add_system("s1", ECSSystem.new())
	_world.add_system("s2", ECSSystem.new())
	_world.add_system("s2", ECSSystem.new())
	_world.add_system("s3", ECSSystem.new())
	print("")
	
func test_remove_component() -> void:
	_entity.remove_component("c1")
	_entity.remove_component("c3")
	
	var list: Array = _entity.get_components()
	print("entity component list:")
	for c: ECSComponent in list:
		print("component [%s]" % c)
	print("")
	
func test_remove_entity() -> void:
	_entity.destroy()
	
	var entity_id_list: Array = _world.get_entity_keys()
	print("entity id list:")
	if entity_id_list.is_empty():
		print("entity id list is empty.")
	else:
		for entity_id: int in entity_id_list:
			print("entity id [%d]" % entity_id)
	var component_list: Array = _world.view("c2")
	print("component list:")
	if component_list.is_empty():
		print("component list is empty.")
	else:
		for c: ECSComponent in component_list:
			print("component [%s]" % c)
	print("")
	
func test_remove_system() -> void:
	_world.remove_system("s1")
	_world.remove_system("s3")
	printt("system list:", _world.get_system_keys())
	print("")
	
func mixed_test() -> void:
	var e: ECSEntity = _world.create_entity()
	e.add_component("c1", ECSComponent.new())
	e.add_component("c2", ECSComponent.new())
	e.add_component("c3", ECSComponent.new())
	
	_entity = _world.create_entity()
	_entity.add_component("c1", ECSComponent.new())
	_entity.add_component("c2", ECSComponent.new())
	_entity.add_component("c3", ECSComponent.new())
	_world.add_system("s1", ECSSystem.new())
	
	var component_list: Array = _world.view("c1")
	print("mixed test component list:")
	for c: ECSComponent in component_list:
		print("component [%s] entity [%d]" % [c.name(), c.entity().id()])
	
	component_list = _world.view("c1", func(c: ECSComponent) -> bool:
		return false)
	printt("view component list with filter:", component_list)
	
	printt("mixed test system list:", _world.get_system_keys())
	printt("multi view list:", _world.multi_view(["c1", "c2"]))
	printt("multi view list with filter:", _world.multi_view(["c1", "c2"], func(dict: Dictionary) -> bool:
		return false))
	
func test_snapshot() -> void:
	var packer := ECSWorldPacker.new(_world)
	var pack := packer.pack_world()
	print("\nworld snapshot:")
	print(pack.data())
	
	print("")
	
class event_tester extends ECSSystem:
	func _on_enter(w: ECSWorld) -> void:
		w.add_callable("test", _on_event)
		pass
	func _on_exit(w: ECSWorld) -> void:
		w.remove_callable("test", _on_event)
	func _on_event(e: ECSEvent) -> void:
		printt("system [%s] on event [%s] with param [%s]" % [self.name(), e.name, e.data])
	
class callable_event_tester extends  ECSSystem:
	func _on_enter(w: ECSWorld) -> void:
		w.add_callable("test", _on_event)
	func _on_exit(w: ECSWorld) -> void:
		w.remove_callable("test", _on_event)
	func _on_event(e: ECSEvent) -> void:
		printt("system [%s] on event [%s] with param [%s]" % [self.name(), e.name, e.data])
	
func test_event() -> void:
	print("begin test add_listener for event:")
	_world.add_system("test_event_system", event_tester.new())
	_world.notify("test", "hello test event.")
	_world.remove_system("test_event_system")
	_world.notify("test", "hello test event.")
	
	print("\nbegin test add_callable for event:")
	_world.add_system("test_event_system", callable_event_tester.new())
	_world.notify("test", "hello test event.")
	_world.remove_system("test_event_system")
	_world.notify("test", "hello test event.")
	
	print("")
	
class _cmd extends ECSCommand:
	func _init() -> void:
		print("test command init.")
	func _on_execute(e: ECSEvent) -> void:
		print("test command execute.")
	
func test_command() -> void:
	_world.add_command("test_cmd_1", _cmd)
	_world.add_command("test_cmd_2", _cmd)
	
	_world.notify("test_cmd_2")
	
	printt("has command", _world.has_command("test_cmd_1"))
	
	_world.remove_command("test_cmd_1")
	_world.notify("test_cmd_1")
	
	printt("has command", _world.has_command("test_cmd_1"))
	print("")
	
func test_entity_add_to_group() -> void:
	var e: ECSEntity = _world.create_entity()
	e.add_to_group("battle")
	e.add_to_group("attack")
	printt("entity group list:", e.get_groups())
	e.remove_from_group("battle")
	printt("entity group list:", e.get_groups())
	var battle_entity_list: Array = _world.fetch_entities("battle")
	printt("battle entity size:", battle_entity_list.size())
	
	
