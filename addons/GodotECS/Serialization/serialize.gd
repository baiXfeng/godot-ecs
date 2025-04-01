extends RefCounted

const Archive = preload("archive.gd")
const InputArchive = preload("input_archive.gd")
const OutputArchive = preload("output_archive.gd")
const InOutArchive = preload("inout_archive.gd")

func pack(ar: Archive) -> void:
	_on_pack(ar)
	
func unpack(ar: Archive) -> void:
	_on_unpack(ar)
	
func convert(ar: Archive) -> void:
	_on_convert(ar)
	
func test() -> void:
	_on_test()
	
# override
func _on_pack(ar: Archive) -> void:
	pass
	
# override
func _on_unpack(ar: Archive) -> void:
	pass
	
# override
func _on_convert(ar: Archive) -> void:
	pass
	
# override
func _on_test() -> void:
	pass
	
