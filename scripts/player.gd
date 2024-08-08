extends CharacterBody2D

@export var speed: float = 100.0 
@export var speed_of_bullet: float = 350.0
var velocity_: Vector2 = Vector2.ZERO
var last_key: String = "down"
var last_direction: Vector2 = Vector2.DOWN
@onready var enemy: CharacterBody2D = get_parent().get_node("Enemy2_0")
@onready var timer2 = get_tree().current_scene.get_node("Timer2")
@onready var timer3 = get_tree().current_scene.get_node("Timer3")
var mouse_pos: Vector2
var bullet_scene = preload("res://scenes/bullet.tscn")
var in_area = false
var attacking = false
var mode = 1
var start_position: Vector2 = Vector2.ZERO
var end_position: Vector2 = Vector2.ZERO
var t = 0.0
var moving = false
var shooting = false
var in_game = false

func _ready():
	if get_tree().current_scene.name == "MainScene":
		mouse_pos = position
		start_position = position
		end_position = position
		t = 0.0
		moving = false
		shooting = false
		in_game = false
	$PlayerAnimator.play("Player_animations/Idle_forward")
	$PlayerAnimator.connect("animation_finished", Callable(self, "_on_animation_finished"))
	timer2.start()
	timer2.one_shot = false
	timer2.wait_time = 2.5
	timer2.connect("timeout", Callable(self, "on_timer_timeout2"))
	timer3.connect("timeout", Callable(self, "on_timer_timeout3"))

func _physics_process(delta):
	if moving:
		if t < 1.0:
			t += delta * (speed / start_position.distance_to(end_position))
			t = clamp(t, 0.0, 1.0)
			position = start_position.lerp(end_position, t)
			velocity = Vector2.ZERO
		else:
			moving = false
				
	mouse_pos = get_global_mouse_position()

	if start_position == Vector2.ZERO:
		start_position = position
	if end_position == Vector2.ZERO:
		end_position = mouse_pos

	mouse_movement()
	velocity = velocity_
	move_and_slide()
	
	if shooting:
		var bullet = bullet_scene.instantiate()
		bullet.position = global_position
		bullet.direction = (mouse_pos - global_position).normalized() 
		bullet.speed = speed_of_bullet
		get_parent().add_child(bullet)
		bullet.add_to_group("bullets")
		shooting = false
		
	if $Camera2D/UI/Health_fill.value <= 0:
		"""get_tree().change_scene_to_file("res://scenes/died_scene.tscn")"""
		
func _input(event):
	var direction = Vector2.ZERO
	
	if Input.is_action_just_pressed("1"):
		mode = 1
	
	if Input.is_action_just_pressed("2"):
		mode = 2
		
	if Input.is_action_pressed("move"):
		mouse_pos = get_global_mouse_position()
		start_position = position
		end_position = mouse_pos
		t = 0.0
		moving = true
		
	if Input.is_action_pressed("move_up"):
		end_position = position
		direction.y -= 1
		last_key = "up"
		last_direction = Vector2.UP
		moving = true
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_backwards")
			
	if Input.is_action_pressed("move_down"):
		end_position = position
		direction.y += 1
		last_key = "down"
		last_direction = Vector2.DOWN
		moving = true
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_forward")

	if Input.is_action_pressed("move_right"):
		end_position = position
		direction.x += 1
		last_key = "right"
		last_direction = Vector2.RIGHT
		moving = true
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_right")

	if Input.is_action_pressed("move_left"):
		end_position = position
		direction.x -= 1
		last_key = "left"
		last_direction = Vector2.LEFT
		moving = true
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_left")
	
	velocity_ = direction.normalized() * speed
	
	if Input.is_action_just_pressed("attack"):
		if mode == 1 and !moving:
			attacking = true
			match last_key:
				"right":
					if !moving:
						$PlayerAnimator.play("Player_animations/Attack_right")
				"left":
					if !moving:
						$PlayerAnimator.play("Player_animations/Attack_left")
				"up":
					if !moving:
						$PlayerAnimator.play("Player_animations/Attack_left")
				"down":
					if !moving:
						$PlayerAnimator.play("Player_animations/Attack_right")
				_:
					print("no last key found")

			if enemy != null and enemy.is_in_group("Goblin") and in_area and !moving:
				enemy_take_damage(enemy)

		if mode == 2:
			if in_game == false:
				if get_tree().current_scene.name == "MainScene":
					mouse_pos = get_global_mouse_position()
					start_position = position
					end_position = mouse_pos
					t = 0.0
					shooting = true

func mouse_movement():
	var direction = mouse_pos - global_position
	var new_direction = direction.normalized()
	
	if new_direction.x > 0.5:
		last_key = "right"
		last_direction = Vector2.RIGHT
		if not attacking and $PlayerAnimator.current_animation != "Player_animations/Idle_right" and !moving:
			$PlayerAnimator.play("Player_animations/Idle_right")
			
	elif new_direction.x < -0.5:
		last_key = "left"
		last_direction = Vector2.LEFT
		if not attacking and $PlayerAnimator.current_animation != "Player_animations/Idle_left" and !moving: 
			$PlayerAnimator.play("Player_animations/Idle_left")
			
	elif new_direction.y > 0.5:
		last_key = "down"
		last_direction = Vector2.DOWN
		if not attacking and $PlayerAnimator.current_animation != "Player_animations/Idle_forward" and !moving:
			$PlayerAnimator.play("Player_animations/Idle_forward")
			
	elif new_direction.y < -0.5:
		last_key = "up"
		last_direction = Vector2.UP
		if not attacking and $PlayerAnimator.current_animation != "Player_animations/Idle_backward" and !moving:
			$PlayerAnimator.play("Player_animations/Idle_backward")

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

func _on_button_pressed():
	mode = 1

func _on_button_2_pressed():
	mode = 2
