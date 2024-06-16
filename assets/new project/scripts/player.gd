extends CharacterBody2D

const SPEED = 200.00
const DASH_SPEED = 600.00
const JUMP_VELOCITY = -400.0
const WALLJUMP_DISTANCE = 20

#Numerical variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1
var acceleration = 20
var jump_speed = -1000

#Bool variables
var dashing = false
var can_dash = true
var can_climb_on_wall = true

#HP system variables
var maxHealth = 10
var health = 10

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
	playersHealth()

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if(velocity.y > 0):
			velocity.y += 1.25*gravity * delta

func handle_jump(delta):
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY

func handle_wall_interactions(delta):
	if $".".is_on_wall_only():
		velocity.y *= 0.65
		if Input.is_action_pressed("get_stopped_near_wall"):
			velocity.y = 0
		if wall_left() == true and Input.is_action_just_pressed("jump") and can_climb_on_wall == true:
			can_climb_on_wall = false;
			$walll_climbing_timer.start()
			direction = 1
			animation.flip_h = false
			velocity.x = 1000
			velocity.y = -300
		elif wall_right() == true and Input.is_action_just_pressed("jump") and can_climb_on_wall == true:
			can_climb_on_wall = false;
			$walll_climbing_timer.start()
			direction = -1
			animation.flip_h = true
			velocity.x = -1000
			velocity.y = -300
		if ((Input.is_action_pressed("go_left") and wall_left() == true) or (Input.is_action_pressed("go_right") and wall_right() == true)) and Input.is_action_just_pressed("jump"):
			velocity.y *= 1.2
			velocity.x *= 0.3

func handle_dash(delta):
	if Input.is_action_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		$dash_timer.start()
		$can_dash_timer.start()

func handle_movement(delta):
	direction = Input.get_axis("go_right", "go_left")
	if direction:
		if dashing:
			velocity.x = -direction * DASH_SPEED
		else:
			if direction == -1:
				animation.flip_h = false
				if is_on_floor():
					animation.play("running")
				else:
					animation.play("idle")
				velocity.x = min(velocity.x + acceleration,SPEED)
			elif direction == 1:
				animation.flip_h = true
				if is_on_floor():
					animation.play("running")
				else:
					animation.play("idle")
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



func playersHealth():
	if health == 0:
		print ("You died")
		get_tree().reload_current_scene()
		
func setHealth(temp):
	health = temp


func wall_right():
	return $RayCast2DRight.is_colliding()
func wall_left():
	return $RayCast2DLeft.is_colliding()
func platform_right():
	return $RayCast2DRight.is_colliding()

#Timers
func _on_timer_timeout():
	dashing = false
func _on_can_dash_timeout():
	can_dash = true
func _on_walll_climbing_timer_timeout():
	can_climb_on_wall = true
