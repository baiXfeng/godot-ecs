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
		
		# who load data
		var entity: ECSEntity = view("player_unit").front().entity()
		var my_comp: MyComponent = entity.get_component("my_component")
		
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
	
