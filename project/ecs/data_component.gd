extends ECSComponent
class_name ECSDataComponent

var data

signal on_data_changed(sender: ECSDataComponent, data)

func _init(d):
	data = d
	
func set_data(d):
	data = d
	on_data_changed.emit(self, data)
	
