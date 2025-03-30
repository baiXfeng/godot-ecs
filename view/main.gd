extends Node2D

# get global ecs world
var _world: ECSWorld = Singleton.world
	
@onready var _score = $VBoxContainer/Scroe
@onready var _time = $VBoxContainer/Time
@onready var _tips = $VBoxContainer/Tips
	
func _enter_tree() -> void:
	_world.add_system("game_system", preload("../system/game_system.gd").new())
	
func _exit_tree() -> void:
	_world.remove_system("game_system")
	
func _ready():
	_connect_components()
	
	# listen ecs world system viewed signal
	_world.on_system_viewed.connect(_print_system_viewed)
	
	# listen game save/load event
	_world.add_callable("game_saved", _on_game_saved)
	_world.add_callable("game_loaded", _on_game_loaded)
	
	# load game data
	_world.notify("load_game_command")
	
func _connect_components():
	for c: MyComponent in _world.view("my_component"):
		c.on_score_changed.connect(_on_score_changed)
		c.on_seconds_changed.connect(_on_seconds_changed)
	
func _on_game_data_event(e: ECSEntity, c: ECSComponent):
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
	
func _on_game_loaded(e: ECSEvent):
	_connect_components()
	
	_tips.text = "Game data loaded."
	await get_tree().create_timer(1).timeout
	_tips.text = ""
	
func _on_game_saved(e: ECSEvent):
	_tips.text = "Game data saved."
	await get_tree().create_timer(1).timeout
	_tips.text = ""
	
func _on_score_changed(value: int):
	_score.text = "Score: %d" % value
	
func _on_seconds_changed(value: float):
	_time.text = "Seconds: %.2f" % value
	
func _on_load_pressed() -> void:
	# load data
	_world.notify("load_game_command")
	
func _on_save_pressed() -> void:
	# save data
	_world.notify("save_game_command")
	
func _print_system_viewed(system: String, components: Array):
	if system == "my_system":
		return
	printt("System/Components:", system, components)
	
