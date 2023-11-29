extends CharacterBody3D

@export var camaraSens = .1
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouseDelta := Vector2()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion and (
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	):
		mouseDelta = event.relative


func _process(delta):
	var vista = $PivoteVista.get_rotation_degrees()
	var giro = get_rotation_degrees()
	
	# Generando rotacion en vista eje X y corrigiendo valor
	vista -= Vector3(rad_to_deg(mouseDelta.y),0,0) * camaraSens * delta
	# Limitando rotacion vertical
	vista.x = clamp(vista.x, -90, 70)
	# Generando rotacion jugador en eje Y y corrigiendo valor
	giro -= Vector3(0,rad_to_deg(mouseDelta.x),0) * camaraSens * delta
#	# Enviando valores
	$PivoteVista.set_rotation_degrees(vista)
	set_rotation_degrees(giro)
	# Reinicar mouseDelta
	mouseDelta = Vector2.ZERO


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
