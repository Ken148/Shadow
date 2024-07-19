extends CharacterBody2D

var speed = 200
var velocity_ = Vector2()

func get_input():
	var direction = Vector2()
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		$Sprite2D/EnemyAnimation.play("Turn_backwards")
		
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		$Sprite2D/EnemyAnimation.play("Turn_forward")
		
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		$Sprite2D/EnemyAnimation.play("Turn_right")
		
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	velocity_ = direction.normalized() * speed

func _physics_process(delta):
	get_input()
	move_and_collide(velocity_ * delta)
