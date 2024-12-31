extends Node
# Autoload named Lobby

const Player = preload("res://Scenes/player.tscn")
const PORT = 9999
var peer = ENetMultiplayerPeer.new()


func _on_host_button_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id()) # adding server player


func _on_join_button_pressed():
	peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = peer


func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
#@rpc("call_local", "reliable")
#func load_game(game_scene_path):
	#get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
#@rpc("any_peer", "call_local", "reliable")
#func player_loaded():
	#if multiplayer.is_server():
		#players_loaded += 1
		#if players_loaded == players.size():
			#$/root/Game.start_game()
			#players_loaded = 0


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
#func _on_player_connected(id):
	#_register_player.rpc_id(id, player_info)
	#print("Player joined: " + str(id) +", " + str(player_info))



#@rpc("any_peer", "reliable")
#func _register_player(new_player_info):
	#var new_player_id = multiplayer.get_remote_sender_id()
	#players[new_player_id] = new_player_info
	#player_connected.emit(new_player_id, new_player_info)


#func _on_player_disconnected(id):
	#players.erase(id)
	#player_disconnected.emit(id)
	#print("Player left: " + str(id) +", " + str(player_info))


#func _on_connected_ok():
	#var peer_id = multiplayer.get_unique_id()
	#players[peer_id] = player_info
	#player_connected.emit(peer_id, player_info)
	## spawn the player model (in host)
	#print("Server joined")



#func _on_connected_fail():
	#multiplayer.multiplayer_peer = null


#func _on_server_disconnected():
	#multiplayer.multiplayer_peer = null
	#players.clear()
	#server_disconnected.emit()
	#print("Server closed")


## RECEIVED SIGNALS
