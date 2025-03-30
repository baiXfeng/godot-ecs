extends ECSCommand

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
		
		# restore the world
		var packer := ECSWorldPacker.new(world())
		var pack := ECSWorldPack.new(game_data)
		packer.unpack_world(pack)
		
		# notify game data
		e.event_center.notify("game_loaded")
	
func _load_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		return f.get_var()
	return {}
	
