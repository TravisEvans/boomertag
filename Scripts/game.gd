extends Node
# Autoload named Lobby

const Player = preload("res://Scenes/player.tscn")
const World = preload("res://Scenes/world.tscn")
const PORT = 9999
var peer = ENetMultiplayerPeer.new()

@onready var address_entry = $UI/PauseMenu/PanelContainerRight/MarginContainer/VBoxContainer/IPAddress


func _on_host_button_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	# Create world
	remove_child($Splash)
	add_child(World.instantiate())
	
	add_player(multiplayer.get_unique_id()) # adding server player
	
	upnp_setup()


func _on_join_button_pressed():
	peer.create_client("localhost" if address_entry.text == "" else address_entry.text, PORT)
	multiplayer.multiplayer_peer = peer
	
	# Create world
	remove_child($Splash)
	add_child(World.instantiate()) ## ???



func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	player.collision_layer = 3
	add_child(player)


func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player: player.queue_free()


func _on_ui_left_game() -> void:
	peer.peer_disconnected.emit()
	peer.close()



## UPNP

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP discover failed. Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP invalid gateway.")
	
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP port mapping failed. Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
	
