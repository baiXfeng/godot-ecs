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
func _on_save(ar: Archive) -> void:
	ar.set_var("value1", value1)
	ar.set_var("value2", value2)
	
# override
func _on_load(ar: Archive) -> void:
	value1 = ar.get_var("value1", 0)
	value2 = ar.get_var("value2", 0.0)
	
# override
func _on_convert(ar: Archive) -> void:
	match ar.version:
		1:
			# some modify ...
			pass
		2:
			# some modify ...
			pass
	
# override
func _on_test() -> void:
	pass
	
