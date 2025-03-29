extends ECSSystem

func _init() -> void:
	super._init(Singleton)
	
# override
func _on_enter(w: ECSWorld) -> void:
	# init
	_init_entity()
	
	# add system
	w.add_system("my_system", preload("my_system.gd").new(self))
	
	# add command, use class resource, not instance
	w.add_command("save_game_command", preload("save_game_command.gd"))
	w.add_command("load_game_command", preload("load_game_command.gd"))
	
	# debug print on
	w.debug_print = true
	w.debug_entity = true
	# ignore on_process log
	w.ignore_notify_log["on_process"] = true
	
# override
func _on_exit(w: ECSWorld) -> void:
	# remove system
	w.remove_system("my_system")
	
	# remove command
	w.remove_command("save_game_command")
	w.remove_command("load_game_command")
	
	# free
	_free_entity()
	
func _init_entity():
	# create entity
	var e = world().create_entity()
	# add component
	e.add_component("player_unit")
	e.add_component("my_component", MyComponent.new())
	
	# create game data entity
	var game_data = world().create_entity()
	game_data.add_component("game_data")
	
func _free_entity():
	world().remove_all_entities()
	
