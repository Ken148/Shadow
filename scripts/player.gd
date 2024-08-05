extends CharacterBody2D

@export var speed: float = 200.0 
@export var speed_of_bullet: float = 350.0
var velocity_: Vector2 = Vector2.ZERO
var last_key: String = "down"
var last_direction: Vector2 = Vector2.DOWN
@onready var enemy: CharacterBody2D = get_parent().get_node("Enemy2_0")
@onready var timer2 = get_tree().current_scene.get_node("Timer2")
var bullet_scene = preload("res://scenes/bullet.tscn")
var in_area = false
var attacking = false
var mode = 1

func get_input():
	if Input.is_action_just_pressed("1"):
		mode = 1
	if Input.is_action_just_pressed("2"):
		mode = 2

	var direction = Vector2.ZERO

	if $Camera2D/UI/Health_fill.value <= 0:
		get_tree().change_scene_to_file("res://scenes/died_scene.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		attacking.instance()

	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		last_key = "up"
		last_direction = Vector2.UP
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_backwards")
			
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		last_key = "down"
		last_direction = Vector2.DOWN
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_forward")

	if Input.is_action_pressed("move_right"):
		direction.x += 1
		last_key = "right"
		last_direction = Vector2.RIGHT
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_right")

	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		last_key = "left"
		last_direction = Vector2.LEFT
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_left")
	
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right"):
		last_direction = (Vector2.UP + Vector2.RIGHT).normalized()
		
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_left"):
		last_direction = (Vector2.UP + Vector2.LEFT).normalized()
		
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_right"):
		last_direction = (Vector2.DOWN + Vector2.RIGHT).normalized()
		
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left"):
		last_direction = (Vector2.DOWN + Vector2.LEFT).normalized()

	velocity_ = direction.normalized() * speed 

	if direction.length() == 0 and not attacking:
		match last_key:
			"right":
				$PlayerAnimator.play("Player_animations/Idle_right")
			"left":
				$PlayerAnimator.play("Player_animations/Idle_left")
			"up":
				$PlayerAnimator.play("Player_animations/Idle_backward")
			"down":
				$PlayerAnimator.play("Player_animations/Idle_forward")

	if Input.is_action_just_pressed("attack") and not attacking and not Input.is_action_pressed("block"):
		attacking = true
		match last_key:
			"right":
				$PlayerAnimator.play("Player_animations/Attack_right")
			"left":
				$PlayerAnimator.play("Player_animations/Attack_left")
			"up":
				$PlayerAnimator.play("Player_animations/Attack_left")  
			"down":
				$PlayerAnimator.play("Player_animations/Attack_right")  
			_:
				print("no last key found")

		if enemy != null:
			if enemy.is_in_group("Goblin") and in_area:
				enemy_take_damage(enemy)

		if mode == 2:
			var bullet = bullet_scene.instantiate()
			bullet.position = global_position
			bullet.direction = last_direction  
			bullet.speed = speed_of_bullet 
			get_parent().add_child(bullet)

	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	get_input()
	velocity = velocity_
	move_and_slide()

func _ready():
	$PlayerAnimator.play("Player_animations/Idle_forward")
	$PlayerAnimator.connect("animation_finished", Callable(self, "_on_animation_finished"))
	timer2.start()
	timer2.one_shot = false
	timer2.wait_time = 2.5
	timer2.connect("timeout", Callable(self, "on_timer_timeout2"))
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func enemy_take_damage(target: CharacterBody2D):
	if target.has_method("take_damage"):
		target.take_damage(20)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Goblin"):
		enemy = body
		in_area = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Goblin"):
		enemy = null
		in_area = false

func on_timer_timeout2():
	$Camera2D/UI/Health_fill.value += 10

func _on_animation_finished(anim_name: String):
	if (anim_name == "Player_animations/Attack_right" or
		anim_name == "Player_animations/Attack_left" or
		anim_name == "Player_animations/Attack_up" or
		anim_name == "Player_animations/Attack_down"):
		attacking = false

func _on_area_2d_2_body_entered(body):
	if body.is_in_group("Goblin"):
		enemy = body
		in_area = true

func _on_area_2d_2_body_exited(body):
	if body.is_in_group("Goblin"):
		enemy = null
		in_area = false
