extends ECSComponent
class_name MyComponent

var value1: int:
	set(v):
		value1 = v
		on_score_changed.emit(value1)

var value2: float:
	set(v):
		value2 = v
		on_seconds_changed.emit(value2)

signal on_score_changed(value: int)
signal on_seconds_changed(value: float)

# override
func _on_save(dict: Dictionary):
	dict["value1"] = value1
	dict["value2"] = value2

# override
func _on_load(dict: Dictionary):
	value1 = dict["value1"] as int
	value2 = dict["value2"] as float
	
