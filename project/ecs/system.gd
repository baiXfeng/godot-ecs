extends Node
class_name ecs_system

var _name: String
var _world: WeakRef

func name() -> String:
	return _name
	
func world() -> ecs_world:
	return _world.get_ref()
	
func view(name: String) -> Array:
	return world().view(name)
	
func group(name: String) -> Array:
	return world().group(name)
	
func get_remote_sender_id() -> int:
	return multiplayer.get_remote_sender_id()
	
func get_rpc_unique_id() -> int:
	return multiplayer.get_unique_id()
	
func is_server() -> bool:
	return multiplayer.is_server()
	
func is_peer_connected() -> bool:
	return peer().get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
	
func peer() -> MultiplayerPeer:
	return multiplayer.multiplayer_peer
	
func set_peer(peer: MultiplayerPeer):
	multiplayer.multiplayer_peer = peer
	
func on_enter(w: ecs_world):
	if w.debug_print:
		print("system <%s:%s> on_enter." % [world().name(), _name])
	_on_enter(w)
	
func on_exit(w: ecs_world):
	if w.debug_print:
		print("system <%s:%s> on_exit." % [world().name(), _name])
	_on_exit(w)
	
func notify(event_name: String, value = null):
	world().notify(event_name, value)
	
func send(e: ecs_event):
	world().send(e)
	
# ==============================================================================
# override function
	
# override
func _on_enter(w: ecs_world):
	pass
	
# override
func _on_exit(w: ecs_world):
	pass
	
# ==============================================================================
# private function
	
func _init(parent: Node = null):
	if parent:
		parent.add_child(self)
	
func _set_name(n: String):
	_name = n
	
func _set_world(w: ecs_world):
	_world = weakref(w)
	
func _to_string() -> String:
	return "system:%s" % _name
	
