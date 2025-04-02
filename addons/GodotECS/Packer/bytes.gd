extends RefCounted
class_name ECSBytes

var _data: PackedByteArray
var _offset: int

static func open(path: String) -> ECSBytes:
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		var bytes := f.get_buffer(f.get_length())
		f.close()
		return ECSBytes.new(bytes)
	return null
	
func write(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if not f:
		return false
	var ret := f.store_buffer(_data)
	f.close()
	return ret
	
func data() -> PackedByteArray:
	return _data
	
func encode_var(value: Variant, compression_mode: int = -1) -> void:
	if compression_mode <= -1:
		var bytes := var_to_bytes(value)
		_data.append_array(bytes)
		_offset += bytes.size()
	
	else:
		var bytes := var_to_bytes(value)
		_append_s32(bytes.size())
		_append_array(bytes.compress(compression_mode))
	
func decode_var(compression_mode: int = -1) -> Variant:
	if compression_mode <= -1:
		var var_offset := _offset
		_offset += _data.decode_var_size(_offset)
		return _data.decode_var(var_offset)
	
	var buffer_size: int = _pull_s32()
	var bytes := _pull_array()
	var decom_bytes: PackedByteArray = bytes.decompress(buffer_size, compression_mode)
	return decom_bytes.decode_var(0)
	
func offset() -> int:
	return _offset
	
func seek(offset: int) -> void:
	_offset = offset
	
func _expand(size: int) -> void:
	if _offset + size >= _data.size():
		_data.resize( maxi(_offset + size, _data.size() + size) )
	
func _append_s32(value: int) -> void:
	_expand(4)
	_data.encode_s32(_offset, value)
	_offset += 4
	
func _append_array(bytes: PackedByteArray) -> void:
	_append_s32(bytes.size())
	_data.append_array(bytes)
	_offset += bytes.size()
	
func _pull_s32() -> int:
	var v: int = _data.decode_s32(_offset)
	_offset += 4
	return v
	
func _pull_array() -> PackedByteArray:
	var var_size := _pull_s32()
	var bytes := _data.slice(_offset, _offset + var_size)
	_offset += var_size
	return bytes
	
func _init(bytes: PackedByteArray = []) -> void:
	_data = bytes
	
