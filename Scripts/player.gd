extends CharacterBody3D

const SPEED = 10.0
const SPRINT_SPEED = 15.0
const AIR_STRAFE_ACCELERATION = 500.0 # this is HUGE because of ????? 
const GROUND_ACCELERATION = 1000.0
const SPEED_LIMIT = 1.2
const CROUCH_SPEED = 5.0
const JUMP_VELOCITY = 5.5
const SENSITIVITY = 0.004
const HEIGHT = 2.0
const CROUCH_HEIGHT = 1.2

@onready var camera = $CameraPivot/Camera3D
@onready var uiTempLabel = get_tree().current_scene.get_node("UI/HUD/Label") ##DEBUG
#@onready var cameraPivot = $CameraPivot # the "head" for rotation, idk check this for more info: https://docs.godotengine.org/en/4.0/tutorials/3d/using_transforms.html



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event): # originally yoinked from https://github.com/LegionGames/FirstPersonController
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))


func _physics_process(delta: float) -> void:
	
	# Handle jump. 
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and Input.is_action_pressed("sprint") and is_on_floor() and !Input.is_action_pressed("crouch"): # check if sprinting on ground and NOT crouching
		velocity.x = lerp(velocity.x, (direction.x * SPRINT_SPEED), 0.05)
		velocity.z = lerp(velocity.z, (direction.z * SPRINT_SPEED), 0.05)
	elif velocity.length() > CROUCH_SPEED and is_on_floor() and Input.is_action_pressed("crouch"): # check if crouching on ground with momentum, aka slide
		velocity += get_gravity() # apply gravity
		velocity.x = lerp(velocity.x, velocity.slide(get_floor_normal()).x, 0.01)
		velocity.z = lerp(velocity.z, velocity.slide(get_floor_normal()).z, 0.01)
	elif direction and Input.is_action_pressed("crouch") and is_on_floor(): # check if crouching on ground
		velocity.x = lerp(velocity.x, (direction.x * CROUCH_SPEED), 0.1)
		velocity.z = lerp(velocity.z, (direction.z * CROUCH_SPEED), 0.1)
	elif direction and is_on_floor(): # check if moving on ground
		velocity.x = lerp(velocity.x, (direction.x * SPEED), 0.05)
		velocity.z = lerp(velocity.z, (direction.z * SPEED), 0.05)
	elif is_on_floor(): # check if not moving on ground
		velocity.x = move_toward(velocity.x, 0.0, 0.5)
		velocity.z = move_toward(velocity.z, 0.0, 0.5)
	
	if Input.is_action_just_pressed("debugQuery"): ##DEBUG
		#print("debugging")
		print("
		normal: " + str(get_floor_normal()) + "
		NORMAL lngth: " + str(get_floor_normal().length()) + "
		vel.slide(nrm): " + str(velocity.slide(get_floor_normal())))
	if Input.is_action_just_pressed("debugAction"): ##DEBUG
		velocity*=3
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
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
	
	
	updateDEBUGLabel(direction)
	# I have no fucking clue how effective this is
	move_and_slide()
# END of _physics_process


func crouch(crouchState: bool):
	match crouchState:
		true: # 1. move viewport down, 2. shrink collision box, 3. check if yo hittin yo head
			$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, CROUCH_HEIGHT, 0.1)
		false:
			if $HeadCollision.is_colliding(): # good enough for now for crouch collision
				pass
			else: # get bigger becaue not hittin yo head
				$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, HEIGHT, 0.1)


func checkValidFloorCollision() -> Vector3:
	if get_last_slide_collision() == null:
		return Vector3.ONE
	#elif axis == "x":
		#return get_last_slide_collision().get_normal().x
	#elif axis == "z":
		#return get_last_slide_collision().get_normal().z
	else: return get_last_slide_collision().get_normal()
	return Vector3.ZERO


func updateDEBUGLabel(dir: Vector3) -> void: ##DEBUG
	uiTempLabel.text = "Current directional velocity: " + str(snapped(velocity.x, 0.01)) + ", " + str(snapped(velocity.z, 0.01)) + " 
	Current absolute direction: " + str(snapped(dir.x,0.01)) + "," + str(snapped(dir.z,0.01)) + "
	Current total velocity: " + str(snapped(velocity.length(), 0.01))
