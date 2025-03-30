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
	_write_to_disk(pack.data())
	
	# notify game data
	e.event_center.notify("game_saved")
	
func _write_to_disk(dict: Dictionary):
	var f := FileAccess.open("user://game.save", FileAccess.WRITE)
	if f:
		f.store_var(dict)
		f.close()
	
