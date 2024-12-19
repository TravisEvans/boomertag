extends CharacterBody3D

const SPEED = 10.0
const SPRINT_SPEED = 15.0
const AIR_STRAFE_ACCELERATION = 150.0 # changes air speed 
const GROUND_ACCELERATION = 1000.0 
const SPEED_LIMIT = 0.2 # changes air speed?
const CROUCH_SPEED = 5.0
const JUMP_VELOCITY = 5.5
const SENSITIVITY = 0.003
const HEIGHT = 2.0
const CROUCH_HEIGHT = 1.2

@onready var camera = $CameraPivot/Camera3D
@onready var uiTempLabel = get_tree().current_scene.get_node("UI/HUD/Label") ##DEBUG
@onready var uiLobbyLabel = get_tree().current_scene.get_node("UI/HUD/LobbyLabel") ##DEBUG
#@onready var cameraPivot = $CameraPivot # the "head" for rotation, idk check this for more info: https://docs.godotengine.org/en/4.0/tutorials/3d/using_transforms.html

var wall_jump_count := 0
var sync_interval := 0.1
var time_since_last_sync := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event): # originally yoinked from https://github.com/LegionGames/FirstPersonController
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))


func _physics_process(delta: float) -> void:
	#if multiplayer.is_server(): # This is the server
	
	if get_multiplayer_authority() == multiplayer.get_unique_id(): # This is the local player???
		# Only the local player controls movement
		handleMovementAndInput(delta)
		time_since_last_sync += delta
		if time_since_last_sync >= sync_interval:
			sync_position()
			time_since_last_sync = 0.0

# END of _physics_process


## MOVEMENT AND INPUT

func handleMovementAndInput(delta) -> void:
	if is_on_floor(): # reset wall jump count
		wall_jump_count = 0
	if is_on_wall_only():
		velocity = velocity.slide(get_wall_normal())
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("jump") and is_on_floor(): # Handle jump
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and is_on_wall_only() and wall_jump_count == 0: # Handle wall jump
		velocity.y = JUMP_VELOCITY
		velocity.x += (get_wall_normal().x*velocity.x)*0.5 if velocity.x>0 else -(get_wall_normal().x*velocity.x)*0.5
		velocity.z += (get_wall_normal().z*velocity.z)*0.5 if velocity.z>0 else -(get_wall_normal().z*velocity.z)*0.5
		wall_jump_count+=1
	elif direction and Input.is_action_pressed("sprint") and is_on_floor() and !Input.is_action_pressed("crouch"): # check if sprinting on ground and NOT crouching
		velocity.x = lerp(velocity.x, (direction.x * SPRINT_SPEED), 0.1)
		velocity.z = lerp(velocity.z, (direction.z * SPRINT_SPEED), 0.1)
	elif velocity.length() > CROUCH_SPEED and is_on_floor() and Input.is_action_pressed("crouch"): # check if crouching on ground with momentum, aka slide
		# this checks if ground is flat or otherwise
		var changingVelocity = 0.25 if (get_floor_normal() == Vector3.UP) or get_floor_angle()>deg_to_rad(60.0) else 0.9
		# apply gravity (increased) to allow sliding on slopes, kinda, otherwise do nothing
		velocity += Vector3.ZERO if (get_floor_normal() == Vector3.UP) or get_floor_angle()>deg_to_rad(60.0) else get_gravity()*1.2
		# apply to velocity as normal, with modifiers
		velocity.x = lerp(velocity.x, velocity.slide(get_floor_normal()).x*changingVelocity, 0.01)
		velocity.z = lerp(velocity.z, velocity.slide(get_floor_normal()).z*changingVelocity, 0.01)
	elif direction and Input.is_action_pressed("crouch") and is_on_floor(): # check if crouching on ground
		velocity.x = lerp(velocity.x, (direction.x * CROUCH_SPEED), 0.1)
		velocity.z = lerp(velocity.z, (direction.z * CROUCH_SPEED), 0.1)
	elif direction and is_on_floor(): # check if moving on ground
		velocity.x = lerp(velocity.x, (direction.x * SPEED), 0.05)
		velocity.z = lerp(velocity.z, (direction.z * SPEED), 0.05)
	elif is_on_floor(): # check if not moving on ground
		velocity.x = move_toward(velocity.x, 0.0, 0.5)
		velocity.z = move_toward(velocity.z, 0.0, 0.5)
	
	# Add gravity
	if not is_on_floor():
		velocity += (get_gravity() * delta) if not is_on_wall() else (get_gravity() * delta)/1.375
	# Handle crouching position change
	crouch(Input.is_action_pressed("crouch"))
	
	# Handle air strafing -- https://www.willdonnelly.net/blog/2021-05-16-godot-airstrafe-controller/
	# Project current velocity onto the strafe direction, and compute a capped
	# acceleration such that *projected* speed will remain within the limit.
	var currentSpeed = direction.dot(velocity)
	var accel = GROUND_ACCELERATION * delta if is_on_floor() else AIR_STRAFE_ACCELERATION * delta
	accel = max(0, min(accel, SPEED_LIMIT - currentSpeed))
	# Apply strafe acceleration to velocity and then integrate motion
	velocity += direction * accel
	
	
	if Input.is_action_just_pressed("debugQuery"): ##DEBUG
		print("debugging")
	if Input.is_action_just_pressed("debugAction"): ##DEBUG
		velocity*=3
	if Input.is_action_just_pressed("debugLobbyQuery"): ##DEBUG
		print("Lobby debugging")
	if Input.is_action_just_pressed("debugLobbyAction"): ##DEBUG
		uiLobbyLabel.text += "
		dummy text"
	updateDEBUGLabel(direction) ##DEBUG
	# I have no fucking clue how effective this is
	move_and_slide()

func crouch(crouchState: bool):
	match crouchState:
		true: # 1. move viewport down, 2. shrink collision box, 3. check if yo hittin yo head
			$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, CROUCH_HEIGHT, 0.1)
		false:
			if $HeadCollision.is_colliding(): # good enough for now for crouch collision
				pass
			else: # get bigger becaue not hittin yo head
				$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, HEIGHT, 0.1)

## NETWORKING

@rpc("any_peer", "reliable")
func update_player_position(peer_id, new_position):
	# The server receives this call, updates its state, and broadcasts it to all clients
	if multiplayer.is_server():
		print("hit server")
		# Ensure valid peer ID
		if peer_id in get_tree().current_scene.get_node("Lobby").players:
			position = new_position  # Update server's copy of the player's position
			# Broadcast to all clients
			update_player_position.rpc(peer_id, position)
	else:
		print("hit this one")
		if multiplayer.get_unique_id() == peer_id: # Clients receive the server's updated position
			position = new_position
			print("hit333")


func sync_position():
	# Notify the server of this player's position
	update_player_position.rpc(multiplayer.get_unique_id(), position)

## DEBUG

func updateDEBUGLabel(dir: Vector3) -> void: ##DEBUG
	uiTempLabel.text = "Current directional velocity: " + str(snapped(velocity.x, 0.01)) + ", " + str(snapped(velocity.z, 0.01)) + " 
	Current absolute direction: " + str(snapped(dir.x,0.01)) + "," + str(snapped(dir.z,0.01)) + "
	Current total velocity: " + str(snapped(velocity.length(), 0.01))
