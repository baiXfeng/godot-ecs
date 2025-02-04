extends Node2D

# my component class extends ECSComponent
class my_component extends ECSComponent:
	
	var value1: int:
		set(v):
			value1 = v
			on_score_changed.emit(value1)
	
	var value2: float:
		set(v):
			value2 = v
			on_seconds_changed.emit(value2)
	
	signal on_score_changed(value: int)
	signal on_seconds_changed(value: float)
	
	# override
	func _on_save(dict: Dictionary):
		dict["value1"] = value1
		dict["value2"] = value2
	
	# override
	func _on_load(dict: Dictionary):
		value1 = dict["value1"] as int
		value2 = dict["value2"] as float
	
# my system class extends ECSSystem
class my_system extends ECSSystem:
	
	# override
	func _on_enter(w: ECSWorld):
		w.add_callable("on_process", _on_process)
		
	# override
	func _on_exit(w: ECSWorld):
		w.remove_callable("on_process", _on_process)
		
	func _on_process(e: ECSEvent):
		# event param
		var delta: float = e.data
		# do some thing
		for c in view("my_component") as Array[my_component]:
			c.value1 += 1
			c.value2 += delta
	
# my command extends ECSCommand
class save_game_command extends ECSCommand:
	
	func _init():
		print("save_game_command created.")
	
	# override
	func _on_execute(e: ECSEvent):
		print("save_game_command execute.")
		_on_save_game(e)
	
	func _on_save_game(event: ECSEvent):
		# wrold
		var world: ECSWorld = self.world()
		
		# serialize entity
		var serialize_data = {}
		
		# fetch components
		var player_units = world.view("player_unit")
		for unit in player_units:
			var e: ECSEntity = unit.entity()
			var all_components = e.get_components()
			var entity_data = {}
			# serialize component data to dictionary
			for c in all_components:
				var data = {}
				c.save( data )
				entity_data[ c.name() ] = data
			serialize_data[ "data" ] = entity_data
		
		# print entity serialize data
		printt("serialize data:", serialize_data)
		
		# save to file
		_write_to_disk(serialize_data)
		
		# notify game data
		view("game_data").front().entity().add_component("game:data:saved")
	
	func _write_to_disk(dict: Dictionary):
		var f := FileAccess.open("user://game.save", FileAccess.WRITE)
		if f:
			var data = JSON.stringify(dict)
			f.store_string(data)
			f.close()
	
class load_game_command extends ECSCommand:
	
	func _init():
		print("load_game_command created.")
	
	# override
	func _on_execute(e: ECSEvent):
		print("load_game_command execute.")
		_on_load_game(e)
	
	func _on_load_game(e: ECSEvent):
		
		# load file
		var game_data = _load_json("user://game.save")
		if game_data != null:
			
			# who load data
			var entity: ECSEntity = view("player_unit").front().entity()
			var my_comp: my_component = entity.get_component("my_component")
			
			# load data
			var entity_data: Dictionary = game_data.data
			for key in entity_data.keys():
				match key:
					"my_component":
						my_comp.load(entity_data[key])
			
			# print
			print(game_data)
			
			# notify game data
			view("game_data").front().entity().add_component("game:data:loaded")
	
	func _load_json(path: String):
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			var json_text = f.get_as_text()
			return JSON.parse_string(json_text)
		return null
	
# create ecs world
var _world: ECSWorld = ECSWorld.new()
	
@onready var _score = $VBoxContainer/Scroe
@onready var _time = $VBoxContainer/Time
@onready var _tips = $VBoxContainer/Tips
	
func _ready():
	
	# run ecs test
	ECSTest.new().queue_free()
	
	# debug print on
	_world.debug_print = true
	# ignore on_process log
	_world.ignore_notify_log["on_process"] = true
	
	# create entity
	var e = _world.create_entity()
	# add component
	e.add_component("player_unit", ECSComponent.new())
	e.add_component("my_component", my_component.new())
	
	# game data entity
	var game_data = _world.create_entity()
	game_data.add_component("game_data")
	game_data.on_component_added.connect(_on_game_data_component_added)
	
	# add system
	_world.add_system("my_system", my_system.new())
	
	# add command, use class resource, not instance
	_world.add_command("save_game_command", save_game_command)
	_world.add_command("load_game_command", load_game_command)
	
	# view components with multi keys
	for dict in _world.multi_view(["player_unit", "my_component"]):
		for key in dict:
			printt("key: ", key, "value: ", dict[key])
	
	# connect component
	for c in e.world().view("my_component") as Array[my_component]:
		c.on_score_changed.connect(_on_score_changed)
		c.on_seconds_changed.connect(_on_seconds_changed)
	
	# load game data
	_world.notify("load_game_command")
	
func _on_game_data_component_added(e: ECSEntity, c: ECSComponent):
	match c.name():
		"game:data:loaded":
			# tips
			_tips.text = "Game data loaded."
		"game:data:saved":
			# tips
			_tips.text = "Game data saved."
		_:
			return
	await get_tree().create_timer(1).timeout
	_tips.text = ""
	
func _on_score_changed(value: int):
	_score.text = "Score: %d" % value
	
func _on_seconds_changed(value: float):
	_time.text = "Seconds: %.2f" % value
	
func _process(delta):
	
	# system on process
	_world.notify("on_process", delta)
	
func _on_load_pressed() -> void:
	
	# load data
	_world.notify("load_game_command")
	
func _on_save_pressed() -> void:
	
	# save data
	_world.notify("save_game_command")
	
