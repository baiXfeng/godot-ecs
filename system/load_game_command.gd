extends ECSCommand

func _init():
	print("load_game_command created.")
	
# override
func _on_execute(e: ECSEvent):
	print("load_game_command execute.")
	_on_load_game(e)
	
func _on_load_game(e: ECSEvent):
	
	# load file
	var bytes := ECSBytes.open("user://game.save")
	if bytes == null:
		return
	
	# restore the world
	var packer := ECSWorldPacker.new(world())
	var data = bytes.decode_var()
	var pack := ECSWorldPack.new(data if data else {})
	packer.unpack_world(pack)
	
	# notify game data
	world().notify("game_loaded")
	
