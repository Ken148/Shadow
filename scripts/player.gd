extends CharacterBody2D

var speed = 500
var velocity_ = Vector2()

func get_input():
	var direction = Vector2()
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		$PlayerAnimator.play("Player_animations/Turn_backwards")
		
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		$PlayerAnimator.play("Player_animations/Turn_forward")
		
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		$PlayerAnimator.play("Player_animations/Turn_right")
		
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		$PlayerAnimator.play("Player_animations/Turn_left")
	velocity_ = direction.normalized() * speed

func _physics_process(delta):
	get_input()
	move_and_collide(velocity_ * delta)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
