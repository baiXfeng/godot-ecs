extends ECSCommand

func _init():
	print("save_game_command created.")
	
# override
func _on_execute(e: ECSEvent):
	print("save_game_command execute.")
	
	# pack the world
	var packer := ECSWorldPacker.new(world())
	var pack := packer.pack_world()
	
	# save to file
	var bytes := ECSBytes.new()
	bytes.encode_var(pack.data())
	var successed := bytes.write("user://game.save")
	
	# notify game data
	world().notify("game_saved", {
		"successed": successed,
	})
	
