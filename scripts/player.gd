extends CharacterBody2D

const SPEED = 200.00
const JUMP_VELOCITY = -300.0
const WALLJUMP_DISTANCE = 20

var acceleration = 20
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dodge_direction = 1;
var spaces = 0
var allowDodge = 0
var temp = 0;
var start_position = 0

@onready var ray_cast_2d_right = $RayCast2DRight
@onready var ray_cast_2d_left = $RayCast2DLeft
@onready var animation = $AnimatedSprite2D

func _ready():
	animation.play("idle")
	ray_cast_2d_right.enabled = true
	ray_cast_2d_left.enabled = true
	start_position = position.x


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
				velocity.x = 50
				velocity.y -= 50
			elif ray_cast_2d_right.is_colliding():
				position.x -= 50
				position.y -= 50
		else:
			allowDodge = 1

func handle_dodge(delta):
	if allowDodge == 1 and Input.is_action_just_pressed("jump"):
		temp = 1
		allowDodge = 0
		spaces = 0  # Reset spaces after dodge
		

func handle_wall_interactions(delta):
	if (ray_cast_2d_left.is_colliding() or ray_cast_2d_right.is_colliding()) and is_on_wall() and not is_on_floor():
		velocity.y *= 0.65
	if Input.is_action_pressed("get_stopped_near_wall") and ray_cast_2d_left.is_colliding():
		velocity.y = 0

func handle_movement(delta):
	var direction = Input.get_axis("go_left", "go_right")
	if direction == 1:
		animation.flip_h = false
	elif direction == -1:
		animation.flip_h = true
	if direction:
		dodge_direction = direction
		if direction == 1:
			velocity.x = min((velocity.x + acceleration)*direction,SPEED)
		elif direction == -1:
			velocity.x = max(velocity.x - acceleration,-SPEED)
	else:
		velocity.x = lerp(velocity.x,0.0,0.2)
