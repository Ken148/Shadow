extends CharacterBody2D

var speed = 500
var velocity_ = Vector2()
var last_key

func get_input():
	var direction = Vector2()
	
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		last_key = "up"
		$PlayerAnimator.play("Player_animations/Turn_backwards")
		
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		last_key = "down"
		$PlayerAnimator.play("Player_animations/Turn_forward")
		
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		last_key = "right"
		$PlayerAnimator.play("Player_animations/Turn_right")
		
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		last_key = "left"
		$PlayerAnimator.play("Player_animations/Turn_left")
	velocity_ = direction.normalized() * speed
	
	if direction.x == 0 and direction.y == 0 and last_key=="right":
		$PlayerAnimator.play("Player_animations/Idle_right")
		
	if direction.x == 0 and direction.y == 0 and last_key=="left":
		$PlayerAnimator.play("Player_animations/Idle_left")
	
	if direction.x == 0 and direction.y == 0 and last_key=="up":
		$PlayerAnimator.play("Player_animations/Idle_backward")
	
	if direction.x == 0 and direction.y == 0 and last_key=="down":
		$PlayerAnimator.play("Player_animations/Idle_forward")
	
func _physics_process(delta):
	get_input()
	move_and_collide(velocity_ * delta)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$PlayerAnimator.play("Player_animations/Idle_forward")
