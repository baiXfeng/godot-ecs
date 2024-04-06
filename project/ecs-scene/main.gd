extends Node2D

# my component class extends ecs_component
class my_component extends ecs_component:
	
	var value1: int
	var value2: float
	
	# override
	func _on_save(dict: Dictionary):
		dict["value1"] = value1
		dict["value2"] = value2
	
	# override
	func _on_load(dict: Dictionary):
		value1 = dict["value1"]
		value2 = dict["value2"]
	
# my system class extends ecs_system
class my_system extends ecs_system:
	
	var components: Array
	
	# override
	func _on_enter():
		components = world().fetch_components("my_component")
		
	# override
	func _on_exit():
		# nothing to do
		pass
		
	# override
	func _on_process(delta: float):
		# do something
		for c in components:
			c.value1 += 1
			c.value2 += delta
		
	# override
	func _on_physics_process(delta: float):
		# nothing to do
		pass
		
	# override
	func _list_events() -> Array:
		# event name list for interested
		return ["save"]
		
	# override
	func _on_event(name, param):
		# process event what interested
		match name:
			"save":
				_serialize_entity()
		
	func _serialize_entity():
		# serialize entity
		var serialize_data = {}
		
		# fetch components
		var player_units = world().fetch_components("player_unit")
		for unit in player_units:
			var e: ecs_entity = unit.entity()
			var all_components = e.get_components()
			var entity_data = {}
			# serialize component data to dictionary
			for c in all_components:
				var data = {}
				c.save( data )
				entity_data[ c.name() ] = data
			serialize_data[ e.id() ] = entity_data
		
		# print entity serialize data
		printt("serialize data:", serialize_data)
		
	
# create ecs world
var _world: ecs_world = ecs_world.new()
	
func _ready():
	
	# run ecs test
	# ecs_test.new()
	
	# debug print on
	_world.debug_print = true
	
	# add system
	_world.add_system("my_system", my_system.new())
	
	# create entity
	var e = _world.create_entity()
	# add component
	e.add_component("player_unit", ecs_component.new())
	e.add_component("my_component", my_component.new())
	
func _process(delta):
	
	# system on process
	_world.on_process("my_system", delta)
	
func _on_Button_pressed():
	
	# system on event
	_world.notify("save")
	
