extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.?????????



 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ui_exit() -> void:
	get_tree().quit()


func _on_ui_start_game() -> void:
	#$Server.load_game.rpc("res://Scenes/Game.tscn")
	get_tree().reload_current_scene()

#
#func _on_ui_join_game() -> void:
	#$Server.join_game("")
#
#
#func _on_ui_end_game() -> void:
	#$Server.remove_multiplayer_peer()
#
#
#func _on_ui_create_game() -> void:
	#$Server.create_game()
