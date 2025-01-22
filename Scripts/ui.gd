extends CanvasLayer

signal create_game
signal end_game
signal join_game
signal left_game



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.set_mouse_filter($HUD.MOUSE_FILTER_IGNORE)
	$HUD.hide()
	$PauseMenu.hide()
	$MainMenu.show()


 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $MainMenu.visible: return
	#Check for opening menu
	if Input.is_action_just_pressed("menu") and !$PauseMenu.visible:
		$HUD.hide()
		$PauseMenu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("menu") and $PauseMenu.visible:
		$HUD.show()
		$PauseMenu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_restart_pressed() -> void:
	left_game.emit()
	get_tree().reload_current_scene()


func _on_create_lobby_pressed() -> void:
	create_game.emit()
	$PauseMenu.hide()
	$HUD.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_end_lobby_pressed() -> void:
	left_game.emit()
	end_game.emit()


func _on_join_lobby_pressed() -> void:
	join_game.emit()
	$PauseMenu.hide()
	$HUD.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_resume_pressed() -> void:
	$PauseMenu.hide()
	$HUD.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
