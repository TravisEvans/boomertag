extends CanvasLayer

signal exit

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
