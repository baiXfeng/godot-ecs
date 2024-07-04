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
	func _on_enter(w: ecs_world):
		w.add_callable("on_process", _on_process)
		components = world().view("my_component")
		
	# override
	func _on_exit(w: ecs_world):
		w.remove_callable("on_process", _on_process)
		
	func _on_process(e: ecs_event):
		# event param
		var delta: float = e.data
		# do some thing
		for c in components:
			c.value1 += 1
			c.value2 += delta
	
# my command extends ecs_command
class my_command extends ecs_command:
	
	func _init():
		print("my_command created.")
	
	# override
	func _on_execute(e: ecs_event):
		print("my_command execute.")
		_on_save_game(e)
	
	func _on_save_game(event: ecs_event):
		# wrold
		var world: ecs_world = self.world()
		
		# serialize entity
		var serialize_data = {}
		
		# fetch components
		var player_units = world.fetch_components("player_unit")
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
	ecs_test.new()
	
	# debug print on
	_world.debug_print = true
	
	# create entity
	var e = _world.create_entity()
	# add component
	e.add_component("player_unit", ecs_component.new())
	e.add_component("my_component", my_component.new())
	
	# add system
	_world.add_system("my_system", my_system.new())
	
	# add command, use class resource, not instance
	_world.add_command("save_game_command", my_command)
	
func _process(delta):
	
	# system on process
	_world.notify("on_process", delta)
	
func _on_Button_pressed():
	
	# system on event
	_world.notify("save_game_command")
	
