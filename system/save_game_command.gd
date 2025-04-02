extends ECSCommand

func _init():
	print("save_game_command created.")
	
# override
func _on_execute(e: ECSEvent):
	print("save_game_command execute.")
	_on_save_game(e)
	
func _on_save_game(e: ECSEvent):
	
	# pack the world
	var packer := ECSWorldPacker.new(world())
	var pack := packer.pack_world()
	
	# save to file
	var bytes := ECSBytes.new()
	bytes.encode_var(pack.data())
	bytes.write("user://game.save")
	
	# notify game data
	world().notify("game_saved")
	
