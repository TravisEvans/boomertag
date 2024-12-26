extends CanvasLayer

signal exit
signal create_game
signal start_game
signal end_game
signal join_game
signal crunch_changed(pixValue: float)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.set_mouse_filter($HUD.MOUSE_FILTER_IGNORE)
	$HUD.show()
	$Menu.hide()


 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Check for opening menu
	if Input.is_action_just_pressed("menu") and !$Menu.visible:
		$HUD.hide()
		$Menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("menu") and $Menu.visible:
		$HUD.show()
		$Menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_exit_pressed() -> void:
	exit.emit()


func _on_resume_pressed() -> void:
	get_tree().reload_current_scene()


func _on_create_lobby_pressed() -> void:
	create_game.emit()


func _on_end_lobby_pressed() -> void:
	end_game.emit()


func _on_join_lobby_pressed() -> void:
	join_game.emit()


func _on_start_lobby_pressed() -> void:
	start_game.emit()


func _on_lobby_player_connected(peer_id: Variant, player_info: Variant) -> void:
	$HUD/LobbyLabel.text += "
	player connected"


func _on_lobby_player_disconnected(peer_id: Variant) -> void:
	$HUD/LobbyLabel.text += "
	player disconnected"

func _on_lobby_server_disconnected() -> void:
	$HUD/LobbyLabel.text += "
	server disconnected"


func _on_h_slider_value_changed(pixValue: float) -> void:
	crunch_changed.emit(pixValue)
