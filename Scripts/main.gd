extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#var player = $Player
	#var camera = $Player/CameraPivot/Camera3D
	#player.set_camera(camera, player.get_node("CameraPivot"))


 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ui_exit() -> void:
	get_tree().quit()
