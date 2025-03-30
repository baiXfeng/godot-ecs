extends "output_archive.gd"

# override
func _get_var(key: String, defaultValue):
	if _dict.has(key):
		return _dict[key]
	return defaultValue
	
