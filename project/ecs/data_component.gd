extends ecs_component
class_name ecs_data_component

var data

signal on_data_changed(sender: ecs_data_component, data)

func _init(d):
	data = d
	
func set_data(d):
	data = d
	on_data_changed.emit(self, data)
	
