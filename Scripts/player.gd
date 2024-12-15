extends CharacterBody3D

const SPEED = 10.0
const SPRINT_SPEED = 20.0
const AIR_SPEED = 5.0
const CROUCH_SPEED_MODIFIER = 0.5
const JUMP_VELOCITY = 5.5
const SENSITIVITY = 0.004
const HEIGHT = 2.0
const CROUCH_HEIGHT = 1.2

@onready var camera = $CameraPivot/Camera3D
@onready var uiTempLabel = get_tree().current_scene.get_node("UI/HUD/Label") #DEBUG
#@onready var cameraPivot = $CameraPivot # the "head" for rotation, idk check this for more info: https://docs.godotengine.org/en/4.0/tutorials/3d/using_transforms.html


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event): # originally yoinked from https://github.com/LegionGames/FirstPersonController
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump. 
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Handle crouch
	crouch(Input.is_action_pressed("crouch"))
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and Input.is_action_pressed("sprint") and is_on_floor(): # check if sprinting on ground
		velocity.x = move_toward(velocity.x, (direction.x * SPRINT_SPEED), 1.0)
		velocity.z = move_toward(velocity.z, (direction.z * SPRINT_SPEED), 1.0)
	elif direction and is_on_floor():
		velocity.x = move_toward(velocity.x, (direction.x * SPEED), 0.5)
		velocity.z = move_toward(velocity.z, (direction.z * SPEED), 0.5)
	#elif !is_on_floor(): # SHOULD be air strafing
		#velocity.x = move_toward(velocity.x, (direction.x * AIR_SPEED), 0.085)
		#velocity.z = move_toward(velocity.z, (direction.z * AIR_SPEED), 0.085)
		# I think I might make another Input check to see if !is_on_ground() and
		# add a static air strafe speed w/ interpolation ###
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, 0.5)
		velocity.z = move_toward(velocity.z, 0.0, 0.5)
	# Finally checks for crouching to modify crouch walk speed
	if Input.is_action_pressed("crouch") and is_on_floor():
		velocity.x *= CROUCH_SPEED_MODIFIER
		velocity.z *= CROUCH_SPEED_MODIFIER
	
	updateVelocityLabel(velocity.x, velocity.z)
	# I have no fucking clue how effective this is
	move_and_slide()


func crouch(crouchState: bool):
	match crouchState:
		true: # 1. move viewport down, 2. shrink collision box, 3. slow down character?
			$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, CROUCH_HEIGHT, 0.1)
			#$AnimationPlayer.play("crouch") for future reference
		false:
			$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, HEIGHT, 0.1)
			#$AnimationPlayer.play("idle") for future reference

func updateVelocityLabel(velX: float, velZ: float) -> void: #DEBUG
	uiTempLabel.text = "Current velocity: " + str(snapped(velX, 0.01)) + ", " + str(snapped(velZ, 0.01))
