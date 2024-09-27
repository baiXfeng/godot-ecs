extends RefCounted
class_name ecs_test

var _world: ecs_world = ecs_world.new("ecs_world_test")
var _entity: ecs_entity

func _init():
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
	
func queue_free():
	_entity = null
	_world.clear()
	
func test_entity():
	_entity = _world.create_entity()
	_entity.add_to_group("first_entity")
	_entity.add_to_group("test_group")
	
	var e = _world.get_entity(_entity.id())
	printt("entity id is equality:", e.id() == _entity.id())
	
	var first_entity_group = _world.group("first_entity")
	printt("first entity group:", first_entity_group.size(), first_entity_group.front().id())
	
	var test_entity_group = _world.group("test_group")
	printt("test entity group:", test_entity_group.size(), test_entity_group.front().id())
	
	print("")
	
func test_component():
	_entity.add_component("c1", ecs_component.new())
	_entity.add_component("c2", ecs_component.new())
	_entity.add_component("c3", ecs_component.new())
	_entity.add_component("c4", ecs_data_component.new(11))
	_entity.add_component("c5", ecs_view_component.new(null))
	print("")
	
func test_system():
	_world.add_system("s1", ecs_system.new())
	_world.add_system("s2", ecs_system.new())
	_world.add_system("s2", ecs_system.new())
	_world.add_system("s3", ecs_system.new())
	print("")
	
func test_remove_component():
	_entity.remove_component("c1")
	_entity.remove_component("c3")
	
	var list = _entity.get_components()
	print("entity component list:")
	for c in list:
		print("component [%s]" % c)
	print("")
	
func test_remove_entity():
	_entity.destroy()
	
	var list = _world.get_entity_keys()
	print("entity list:")
	if list.is_empty():
		print("entity list is empty.")
	else:
		for key in list:
			print("entity [%d]" % key)
	list = _world.view("c2")
	print("component list:")
	if list.is_empty():
		print("component list is empty.")
	else:
		for c in list:
			print("component [%s]" % c)
	print("")
	
func test_remove_system():
	_world.remove_system("s1")
	_world.remove_system("s3")
	printt("system list:", _world.get_system_keys())
	print("")
	
func mixed_test():
	var e = _world.create_entity()
	e.add_component("c1", ecs_component.new())
	e.add_component("c2", ecs_component.new())
	e.add_component("c3", ecs_component.new())
	
	_entity = _world.create_entity()
	_entity.add_component("c1", ecs_component.new())
	_entity.add_component("c2", ecs_component.new())
	_entity.add_component("c3", ecs_component.new())
	_world.add_system("s1", ecs_system.new())
	
	var list = _world.view("c1")
	print("mixed test component list:")
	for c in list:
		print("component [%s] entity [%d]" % [c.name(), c.entity().id()])
	printt("mixed test system list:", _world.get_system_keys())
	
func test_snapshot():
	var list = _world.view("c1")
	var data = {}
	for c in list:
		var e: ecs_entity = c.entity()
		var comps = e.get_components()
		var entity_data = {}
		printt("\nstart save entity [%d] ..." % e.id())
		for cc in comps:
			var save_data = {}
			cc.save(save_data)
			var name = cc.name()
			entity_data[ name ] = save_data
			printt("save component:", save_data)
		data[ e.id() ] = entity_data
		printt("entity [%d] save completed." % e.id())
	# save entity data
	print("\nentity snapshot:")
	print(data)
	
	print("")
	
class event_tester extends ecs_system:
	func _on_enter(w: ecs_world):
		w.add_callable("test", _on_event)
		pass
	func _on_exit(w: ecs_world):
		w.remove_callable("test", _on_event)
	func _on_event(e: ecs_event):
		printt("system [%s] on event [%s] with param [%s]" % [self.name(), e.name, e.data])
	
class callable_event_tester extends  ecs_system:
	func _on_enter(w: ecs_world):
		w.add_callable("test", _on_event)
	func _on_exit(w: ecs_world):
		w.remove_callable("test", _on_event)
	func _on_event(e: ecs_event):
		printt("system [%s] on event [%s] with param [%s]" % [self.name(), e.name, e.data])
	
func test_event():
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
	
class _cmd extends ecs_command:
	func _init():
		print("test command init.")
	func _on_execute(e: ecs_event):
		print("test command execute.")
	
func test_command():
	_world.add_command("test_cmd_1", _cmd)
	_world.add_command("test_cmd_2", _cmd)
	
	_world.notify("test_cmd_2")
	
	printt("has command", _world.has_command("test_cmd_1"))
	
	_world.remove_command("test_cmd_1")
	_world.notify("test_cmd_1")
	
	printt("has command", _world.has_command("test_cmd_1"))
	print("")
	
func test_entity_add_to_group():
	var e = _world.create_entity()
	e.add_to_group("battle")
	e.add_to_group("attack")
	printt("entity group list:", e.get_groups())
	e.remove_from_group("battle")
	printt("entity group list:", e.get_groups())
	var list = _world.fetch_entities("battle")
	printt("battle entity size:", list.size())
	
	
