extends CharacterBody2D

var speed = 200 

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		$Sprite2D/EnemyAnimation.play("Turn_backwards")
		
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		$Sprite2D/EnemyAnimation.play("Turn_forward")
		
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		$Sprite2D/EnemyAnimation.play("Turn_right")
		
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		$Sprite2D/EnemyAnimation.play("Turn_left")
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
