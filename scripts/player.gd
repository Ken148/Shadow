extends CharacterBody2D

@export var speed: float = 100.0 
@export var speed_of_bullet: float = 350.0
var velocity_: Vector2 = Vector2.ZERO
var last_key: String = "down"
var last_direction: Vector2 = Vector2.DOWN
@onready var enemy: CharacterBody2D = get_parent().get_node("Enemy2_0")
@onready var timer2 = get_tree().current_scene.get_node("Timer2")
@onready var timer3 = get_tree().current_scene.get_node("Timer3")
@onready var ability_timer = $Timer
@onready var interaction_area = $Attack_range_1/CollisionPolygon2D
var mouse_pos: Vector2
var bullet_scene = preload("res://scenes/bullet.tscn")
var in_area = false
var attacking = false
var mode = 1
var start_position: Vector2 = Vector2.ZERO
var end_position: Vector2 = Vector2.ZERO
var t = 0.0
var shooting = false
var in_game = false
var new_position: Vector2
var direction_vector: Vector2 = Vector2.ZERO
var ability_recharged = true

func _ready():
	if get_tree().current_scene.name == "MainScene":
		mouse_pos = position
		start_position = position
		end_position = position
		t = 0.0
		shooting = false
		in_game = false
	$PlayerAnimator.play("Player_animations/Idle_forward")
	$PlayerAnimator.connect("animation_finished", Callable(self, "_on_animation_finished"))
	timer2.start()
	timer2.one_shot = false
	timer2.wait_time = 2.5
	timer2.connect("timeout", Callable(self, "on_timer_timeout2"))
	timer3.connect("timeout", Callable(self, "on_timer_timeout3"))
	last_key = "down"

func _physics_process(delta):
	mouse_pos = get_global_mouse_position()

	if start_position == Vector2.ZERO:
		start_position = position
	if end_position == Vector2.ZERO:
		end_position = mouse_pos

	var direction = mouse_pos - global_position
	var new_direction = direction.normalized()
	velocity = velocity_
	move_and_slide()
	
	if enemy != null:
		new_position = enemy.position 
		match last_key:
			"up":
				new_position.y -= 50
			"down":
				new_position.y += 50
			"left":
				new_position.x -= 50
			"right":
				new_position.x += 50
			"up_right":
				new_position.y -= 50
				new_position.x += 50
			"up_left":
				new_position.y -= 50
				new_position.x -= 50
			"down_right":
				new_position.y += 50
				new_position.x += 50
			"down_left":
				new_position.y += 50
				new_position.x -= 50
			_:
				print("no last key found")
			
	if shooting:
		if $Camera2D/UI/Health_fill/Mana_fill.value != 0:
			var bullet = bullet_scene.instantiate()
			bullet.position = global_position
			bullet.direction = (mouse_pos - global_position).normalized() 
			bullet.speed = speed_of_bullet
			get_parent().add_child(bullet)
			bullet.add_to_group("bullets")
			shooting = false
			$Camera2D/UI/Health_fill/Mana_fill.value -= 10
		
	if $Camera2D/UI/Health_fill.value <= 0:
		"""get_tree().change_scene_to_file("res://scenes/died_scene.tscn")"""
		
func _input(event):
	var direction = Vector2.ZERO
	
	if Input.is_action_just_pressed("1"):
		mode = 1
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	if Input.is_action_just_pressed("2"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mode = 2
		
	if Input.is_action_just_pressed("3"):
		ability_timer.start()
		enemy.speed = 0
		mode = 3
	if Input.is_action_pressed("sprint"):
		speed = 130.0 
	
	if Input.is_action_just_released("sprint"):
		speed = 100.0 
		
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.is_action_pressed("move_up"):
		end_position = position
		direction.y -= 1
		interaction_area.rotation = deg_to_rad(270)
		last_key = "up"
		last_direction = Vector2.UP
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_backwards")
			
	if Input.is_action_pressed("move_down"):
		end_position = position
		direction.y += 1
		interaction_area.rotation = deg_to_rad(90)
		last_key = "down"
		last_direction = Vector2.DOWN
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_forward")
		
	if Input.is_action_pressed("move_right"):
		end_position = position
		direction.x += 1
		interaction_area.rotation = deg_to_rad(0)
		last_key = "right"
		last_direction = Vector2.RIGHT
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_right")
		
	if Input.is_action_pressed("move_left"):
		end_position = position
		direction.x -= 1
		interaction_area.rotation = deg_to_rad(180)
		last_key = "left"
		last_direction = Vector2.LEFT
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_left")
	
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_up"):
		last_key = "up_left"
		
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_up"):
		last_key = "up_right"
		
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_down"):
		last_key = "down_left"
		
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down"):
		last_key = "down_right"
		
	velocity_ = direction.normalized() * speed
	
	if Input.is_action_just_pressed("attack"):
		if mode == 1:
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

			if enemy != null and enemy.is_in_group("Goblin") and in_area:
				enemy_take_damage(enemy)

		if mode == 2:
			if in_game == false:
				if get_tree().current_scene.name == "MainScene":
					mouse_pos = get_global_mouse_position()
					start_position = position
					end_position = mouse_pos
					t = 0.0
					shooting = true
					
		if mode == 3:
			if ability_recharged:
				position = new_position 

func on_timer_timeout2():
	"""$Camera2D/UI/Health_fill.value += 10"""

func on_timer_timeout3():
	for bullet in get_tree().get_nodes_in_group("bullets"):
		if bullet.is_inside_tree():
			bullet.queue_free()
			in_game = false

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

func _on_animation_finished(anim_name: String):
	if anim_name in ["Player_animations/Attack_right", "Player_animations/Attack_left", "Player_animations/Attack_left", "Player_animations/Attack_right"]:
		attacking = false

func _on_timer_timeout():
	if enemy == null:
		print("Error: Enemy is null")
	else:
		enemy.speed = 10
	ability_recharged = false
