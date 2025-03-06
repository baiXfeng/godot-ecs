extends Node
class_name ECSSystemNode

var _name: String
var _world: WeakRef

func name() -> String:
	return _name
	
func world() -> ECSWorld:
	return _world.get_ref()
	
func view(name: String, filter: Callable = Callable()) -> Array:
	return world().view(name, filter)
	
func multi_view(names: Array[String], filter: Callable = Callable()) -> Array:
	return world().multi_view(names, filter)
	
func group(name: String) -> Array:
	return world().group(name)
	
func get_remote_sender_id() -> int:
	return multiplayer.get_remote_sender_id() if is_inside_tree() else -1
	
func get_rpc_unique_id() -> int:
	return multiplayer.get_unique_id() if is_inside_tree() else -1
	
func is_server() -> bool:
	return multiplayer.is_server() if is_inside_tree() else false
	
func is_peer_connected() -> bool:
	var peer: MultiplayerPeer = peer()
	return peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED if peer else false
	
func peer() -> MultiplayerPeer:
	return multiplayer.multiplayer_peer if is_inside_tree() else null
	
func set_peer(peer: MultiplayerPeer):
	if is_inside_tree():
		multiplayer.multiplayer_peer = peer
	
func on_enter(w: ECSWorld):
	if w.debug_print:
		print("system_node <%s:%s> on_enter." % [world().name(), _name])
	_on_enter(w)
	
func on_exit(w: ECSWorld):
	if w.debug_print:
		print("system_node <%s:%s> on_exit." % [world().name(), _name])
	_on_exit(w)
	queue_free()
	
func notify(event_name: String, value = null):
	world().notify(event_name, value)
	
func send(e: ECSEvent):
	world().send(e)
	
# ==============================================================================
# override function
	
# override
func _on_enter(w: ECSWorld):
	pass
	
# override
func _on_exit(w: ECSWorld):
	pass
	
# ==============================================================================
# private function
	
func _init(parent: Node = null):
	if parent:
		parent.add_child(self)
	
func _set_name(n: String):
	_name = n
	
func _set_world(w: ECSWorld):
	_world = weakref(w)
	
func _to_string() -> String:
	return "system_node:%s" % _name
	
