extends CharacterBody2D

const SPEED = 300.00
const JUMP_VELOCITY = -300.0
const WALLJUMP_DISTANCE = 20

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dodge_direction = 1;
var spaces = 0
var allowDodge = 0

@onready var ray_cast_2d_right = $RayCast2DRight
@onready var ray_cast_2d_left = $RayCast2DLeft

func _ready():
	ray_cast_2d_right.enabled = true
	ray_cast_2d_left.enabled = true

func _physics_process(delta):
	handle_gravity(delta)
	handle_jump(delta)
	handle_dodge(delta)
	handle_wall_interactions(delta)
	handle_movement(delta)
	move_and_slide()

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump(delta):
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			spaces = 1  # Allow for possible dodge
		elif is_on_wall():
			spaces = 0
			if ray_cast_2d_left.is_colliding():
				position.x += 50
				position.y -= 50
			elif ray_cast_2d_right.is_colliding():
				position.x -= 50
				position.y -= 50
		else:
			allowDodge = 1

func handle_dodge(delta):
	if allowDodge == 1 and Input.is_action_just_pressed("jump"):
		position.x += 50 * direction  # Dodge movement
		spaces = 0  # Reset spaces after dodge
		allowDodge = 0

func handle_wall_interactions(delta):
	if (ray_cast_2d_left.is_colliding() or ray_cast_2d_right.is_colliding()) and is_on_wall() and not is_on_floor():
		velocity.y *= 0.5
	if Input.is_action_pressed("get_stopped_near_wall") and ray_cast_2d_left.is_colliding():
		velocity.y = 0

func handle_movement(delta):
	var direction = Input.get_axis("go_left", "go_right")
	if direction:
		dodge_direction = direction
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
