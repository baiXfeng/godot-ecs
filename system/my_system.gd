extends ECSSystem

# override
func _on_enter(w: ECSWorld):
	w.add_callable("on_process", _on_process)
	
# override
func _on_exit(w: ECSWorld):
	w.remove_callable("on_process", _on_process)
	
func _on_process(e: ECSEvent):
	# event param
	var delta: float = e.data
	# do some thing
	for c: MyComponent in view("my_component"):
		c.value1 += 1
		c.value2 += delta
	
