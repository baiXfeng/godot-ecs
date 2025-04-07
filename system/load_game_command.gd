extends ECSCommand

func _init():
	print("load_game_command created.")
	
# override
func _on_execute(e: ECSEvent):
	print("load_game_command execute.")
	
	# load file
	var bytes := ECSBytes.open("user://game.save")
	if bytes == null:
		return
	
	# restore the world
	var packer := ECSWorldPacker.new(world())
	var data = bytes.decode_var()
	var pack := ECSWorldPack.new(data if data else {})
	var successed := packer.unpack_world(pack)
	
	# notify game data
	world().notify("game_loaded", {
		"successed": successed,
	})
	
