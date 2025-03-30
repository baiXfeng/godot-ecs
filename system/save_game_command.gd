extends ECSCommand

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
	
