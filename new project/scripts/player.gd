extends CharacterBody2D

const SPEED = 200.00
const DASH_SPEED = 600.00
const JUMP_VELOCITY = -300.0
const WALLJUMP_DISTANCE = 20

var direction = 0
var jump_speed = -1000
var dashing = false
var can_dash = true
var acceleration = 20
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var player = $"."
@onready var ray_cast_2d_right = $RayCast2DRight
@onready var ray_cast_2d_left = $RayCast2DLeft
@onready var animation = $AnimatedSprite2D
@onready var camera_2d = $Camera2D

func _ready():
	animation.play("idle")
	ray_cast_2d_right.enabled = true
	ray_cast_2d_left.enabled = true


func _physics_process(delta):
	handle_gravity(delta)
	handle_jump(delta)
	handle_wall_interactions(delta)
	handle_movement(delta)
	move_and_slide()
	handle_dash(delta)

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump(delta):
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY

func handle_wall_interactions(delta):
	if $".".is_on_wall_only():
		velocity.y *= 0.65
		if Input.is_action_pressed("get_stopped_near_wall"):
			velocity.y = 0
		if wall_left() == true and Input.is_action_just_pressed("jump"):
			direction = 1
			animation.flip_h = false
			velocity.x = 1000
			velocity.y = -300
		if wall_right() == true and Input.is_action_just_pressed("jump"):
			direction = -1
			animation.flip_h = true
			velocity.x = -1000
			velocity.y = -300

func handle_dash(delta):
	if Input.is_action_pressed("dash") and can_dash:
		dashing = true
		#can_dash = false
		$dash_timer.start()
		#$can_dash_timer.start()

func handle_movement(delta):
	direction = Input.get_axis("go_left", "go_right")
	if direction == 1:
		animation.flip_h = false
		animation.play("running")
	elif direction == -1:
		animation.flip_h = true
		animation.play("running")
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			if direction == 1:
				velocity.x = min(velocity.x + acceleration,SPEED)
			elif direction == -1:
				velocity.x = max(velocity.x - acceleration,-SPEED)
	else:
		if dashing:
			if animation.flip_h:
				velocity.x = -DASH_SPEED
			else:
				velocity.x = DASH_SPEED
		else:
			velocity.x = lerp(velocity.x,0.0,0.2)
			animation.play("idle")


func wall_right():
	return $RayCast2DRight.is_colliding()


func wall_left():
	return $RayCast2DLeft.is_colliding()

#Timers
func _on_timer_timeout():
	dashing = false

func _on_can_dash_timeout():
	can_dash = true
