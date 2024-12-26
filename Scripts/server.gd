extends Node

var peer = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
# var ip = "145.131.21.160"
var port = 1909

func _ready():
	ConnectToServer()

func ConnectToServer():
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	
	# Handle server signals
	#multiplayer.peer_connected.connect(_on_player_connected)
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)
	
func _on_connected_fail():
	print("Failed to connect")

func _on_connected_ok():
	print("Successfully connected")
	rpc_id(1, "send", "sent", "recieved", multiplayer.get_unique_id())

@rpc("any_peer", "reliable")
func send(m1: String, m2: String, id: int):
	pass

@rpc("authority", "call_local")
func recieve(s_m1):
	print(s_m1 + " also")
