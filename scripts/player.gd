extends CharacterBody2D

@export var speed: float = 100.0 
@export var speed_of_bullet: float = 350.0
var velocity_: Vector2 = Vector2.ZERO
var last_key: String = "down"
var last_direction: Vector2 = Vector2.DOWN
@onready var enemy: CharacterBody2D = get_parent().get_node("Enemy2_0")
@onready var timer2 = get_tree().current_scene.get_node("Timer2")
@onready var timer3 = get_tree().current_scene.get_node("Timer3")
@onready var ability_timer = $Ability_timer
@onready var interaction_area = $Knife_range/CollisionPolygon2D
@onready var knife_range = $Knife_range
@onready var ability_3_side = $Ability_3_side

@onready var attack_range_2 = $Attack_range_2
@onready var attack_range_3 = $Attack_range_3
@onready var attack_range_4 = $Attack_range_4
var close = false
var far = false
var very_far = false
var slice_attack = false

var second_hit = false
var wait_sec = 0
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
var ability_in_area = false

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

	# timer connection
	timer2.start()
	timer2.one_shot = false
	timer2.wait_time = 2.5
	timer2.connect("timeout", Callable(self, "on_timer_timeout2"))
	timer3.connect("timeout", Callable(self, "on_timer_timeout3"))
	last_key = "down"

func _physics_process(delta):
	# setting mouse position and direction
	mouse_pos = get_global_mouse_position()
	
	if start_position == Vector2.ZERO:
		start_position = position
	if end_position == Vector2.ZERO:
		end_position = mouse_pos
	
	var direction = mouse_pos - global_position
	var new_direction = direction.normalized()
	velocity = velocity_
	move_and_slide()
	
	# activating monitoring/monitorable
	monitoring_ability()
	
	# rotataing ability 3 
	match last_key:
		"up":
			ability_3_side.rotation = deg_to_rad(270)
			
		"down":
			ability_3_side.rotation = deg_to_rad(90)
			
		"left":
			ability_3_side.rotation = deg_to_rad(180)
			
		"right":
			ability_3_side.rotation = deg_to_rad(0)
			
		"up_right":
			ability_3_side.rotation = deg_to_rad(315)
			
		"up_left":
			ability_3_side.rotation = deg_to_rad(225)
			
		"down_right":
			ability_3_side.rotation = deg_to_rad(45)
			
		"down_left":
			ability_3_side.rotation = deg_to_rad(135)
			
		_:
			print("no last key found")

				
	# saving position for ability 3 to teleport
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
		# creating bullet in mainscene and shooting it in the correct direction
		if $Camera2D/UI/Health_fill/Mana_fill.value != 0:
			var bullet = bullet_scene.instantiate()
			bullet.position = global_position
			bullet.direction = (mouse_pos - global_position).normalized() 
			bullet.speed = speed_of_bullet
			get_parent().add_child(bullet)
			bullet.add_to_group("bullets")
			shooting = false
			$Camera2D/UI/Health_fill/Mana_fill.value -= 10
		
	# changing scenes after death 
	if $Camera2D/UI/Health_fill.value <= 0:
		"""get_tree().change_scene_to_file("res://scenes/died_scene.tscn")"""
		
func _input(event):
	var direction = Vector2.ZERO
	
	# changing modes 1-4
	if Input.is_action_just_pressed("1"):
		mode = 1
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	if Input.is_action_just_pressed("2"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mode = 2
		
	if Input.is_action_just_pressed("3"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		if enemy != null:
			ability_timer.start()
			enemy.speed = 0
			mode = 3
		
	if Input.is_action_just_pressed("4"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		mode = 4
	
	# sprinting
	if Input.is_action_pressed("sprint"):
		speed = 130.0 
	
	if Input.is_action_just_released("sprint"):
		speed = 100.0 
		
	# going to main menu
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# movement, aniamtion, settings last_key pressed
	if Input.is_action_pressed("move_up"):
		monitoring_ability()
		end_position = position
		direction.y -= 1
		interaction_area.rotation = deg_to_rad(270)
		last_key = "up"
		last_direction = Vector2.UP
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_backwards")
			
	if Input.is_action_pressed("move_down"):
		monitoring_ability()
		end_position = position
		direction.y += 1
		interaction_area.rotation = deg_to_rad(90)
		last_key = "down"
		last_direction = Vector2.DOWN
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_forward")
		
	if Input.is_action_pressed("move_right"):
		monitoring_ability()
		end_position = position
		direction.x += 1
		interaction_area.rotation = deg_to_rad(0)
		last_key = "right"
		last_direction = Vector2.RIGHT
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_right")
		
	if Input.is_action_pressed("move_left"):
		monitoring_ability()
		end_position = position
		direction.x -= 1
		interaction_area.rotation = deg_to_rad(180)
		last_key = "left"
		last_direction = Vector2.LEFT
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_left")
	
	# diagonal animation for player and settings last_key pressed	
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_up"):
		monitoring_ability()
		last_key = "up_left"
		$PlayerAnimator.play("Player_animations/Turn_left")
		
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_up"):
		monitoring_ability()
		last_key = "up_right"
		$PlayerAnimator.play("Player_animations/Turn_right")
		
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_down"):
		monitoring_ability()
		last_key = "down_left"
		$PlayerAnimator.play("Player_animations/Turn_left")
		
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down"):
		monitoring_ability()
		last_key = "down_right"
		$PlayerAnimator.play("Player_animations/Turn_right")
	
	# spining player rotation depending on click
	# ------------------------------------------------------------------
	
	# ↗  (Up-Right)
	if Input.is_action_just_pressed("move_up") and last_key == "right":
		monitoring_ability()
		last_key = "up_right"
		$PlayerAnimator.play("Player_animations/Turn_right")
		
	# ↖  (Up-Left)
	if Input.is_action_just_pressed("move_up") and last_key == "left":
		monitoring_ability()
		last_key = "up_left"
		$PlayerAnimator.play("Player_animations/Turn_left")
	
	# ↘  (Down-Right)
	if Input.is_action_just_pressed("move_down") and last_key == "right":
		monitoring_ability()
		last_key = "down_right"
		$PlayerAnimator.play("Player_animations/Turn_right")
	
	# ↙  (Down-Left)
	if Input.is_action_just_pressed("move_down") and last_key == "left":
		monitoring_ability()
		last_key = "down_left"
		$PlayerAnimator.play("Player_animations/Turn_left")
		
	# ------------------------------------------------------------------
	
	# ↗  (Up-Right)
	if Input.is_action_just_pressed("move_right") and last_key == "up":
		monitoring_ability()
		last_key = "up_right"
		$PlayerAnimator.play("Player_animations/Turn_right")
		
	# ↖  (Up-Left)
	if Input.is_action_just_pressed("move_left") and last_key == "up":
		monitoring_ability()
		last_key = "up_left"
		$PlayerAnimator.play("Player_animations/Turn_left")
	
	# ↘  (Down-Right)
	if Input.is_action_just_pressed("move_right") and last_key == "down":
		monitoring_ability()
		last_key = "down_right"
		$PlayerAnimator.play("Player_animations/Turn_right")
	
	# ↙  (Down-Left)
	if Input.is_action_just_pressed("move_left") and last_key == "down":
		monitoring_ability()
		last_key = "down_left"
		$PlayerAnimator.play("Player_animations/Turn_left")
		
	# saving velocity 
	velocity_ = direction.normalized() * speed
	
	# attacking 
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
				"up_left":
						$PlayerAnimator.play("Player_animations/Attack_left")
				"up_right":
						$PlayerAnimator.play("Player_animations/Attack_right")
				"down_left":
						$PlayerAnimator.play("Player_animations/Attack_left")
				"down_right":
						$PlayerAnimator.play("Player_animations/Attack_right")
				_:
					print("no last key found")

			if enemy != null and enemy.is_in_group("Goblin") and in_area:
				enemy_take_damage(enemy)
				slice_attack = true
				attacking = false

		if mode == 2:
			if not in_game:
				if get_tree().current_scene.name == "MainScene":
					mouse_pos = get_global_mouse_position()
					start_position = position
					end_position = mouse_pos
					t = 0.0
					shooting = true
					
		if mode == 3 and ability_in_area:
			if ability_recharged:
				position = new_position
				enemy_take_damage(enemy)
				second_hit = true
				await get_tree().create_timer(2).timeout
				if enemy != null:
					enemy_take_damage(enemy)
				
		if mode == 4:
			if enemy != null:
				enemy_take_damage(enemy)
				await get_tree().create_timer(2).timeout
				if enemy != null:
					enemy_take_damage(enemy)
					await get_tree().create_timer(2).timeout
					if enemy != null:
						enemy_take_damage(enemy)

# player taking damage
func on_timer_timeout2():
	"""$Camera2D/UI/Health_fill.value += 10"""

# bullet removal
func on_timer_timeout3():
	for bullet in get_tree().get_nodes_in_group("bullets"):
		if bullet.is_inside_tree():
			bullet.queue_free()
			in_game = false

# enemy taking damage
func enemy_take_damage(target: CharacterBody2D):
	if target != null and target.has_method("take_damage"):
		if mode == 1:
			if slice_attack:
				target.take_damage(20)
				slice_attack = false
		if mode == 3:
			if second_hit:
				target.take_damage(40)
				second_hit = false
			else:
				target.take_damage(25)
		if mode == 4:
			if close:
				target.take_damage(50)
			elif far:
				target.take_damage(25)
			elif very_far:
				target.take_damage(10)

# checking is enemy is in knife range
func _on_area_2d_body_entered(body):
	if body.is_in_group("Goblin"):
		enemy = body
		in_area = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Goblin"):
		enemy = null
		in_area = false

# waiting for animation end
func _on_animation_finished(anim_name: String):
	if anim_name in ["Player_animations/Attack_right", "Player_animations/Attack_left", "Player_animations/Attack_left", "Player_animations/Attack_right"]:
		attacking = false

# ability enemy moving and stopping
func _on_timer_timeout():
	if enemy == null:
		print("Error: Enemy is null")
	else:
		enemy.speed = 10
	ability_recharged = false

# ability 4 checking for enemy in range
func _on_attack_range_2_body_entered(body):
	if body != null and body.is_in_group("Goblin"):
		close = true
		far = false
		very_far = false

func _on_attack_range_3_body_entered(body):
	if body != null and body.is_in_group("Goblin"):
		far = true
		close = false
		very_far = false

func _on_attack_range_4_body_entered(body):
	if body != null and body.is_in_group("Goblin"):
		very_far = true
		far = false
		close = false

# if enemy leaves range 
func _on_attack_range_2_body_exited(body):
	if body != null and body.is_in_group("Goblin"):
		close = false

func _on_attack_range_3_body_exited(body):
	if body != null and body.is_in_group("Goblin"):
		far = false

func _on_attack_range_4_body_exited(body):
	if body != null and body.is_in_group("Goblin"):
		very_far = false

# ability 3 checking for enemy
func _on_ability_3_side_body_entered(body):
	if body != null and body.is_in_group("Goblin"):
		ability_in_area = true

func _on_ability_3_side_body_exited(body):
	if body != null and body.is_in_group("Goblin"):
		ability_in_area = false

# disabling and enabling colliders 
func monitoring_ability():
	if mode == 1:
		knife_range.monitoring = true
		knife_range.monitorable = true
		
		attack_range_2.monitoring = false
		attack_range_2.monitorable = false
		
		attack_range_3.monitoring = false
		attack_range_3.monitorable = false
		
		attack_range_4.monitoring = false
		attack_range_4.monitorable = false
		
		ability_3_side.monitoring = false
		ability_3_side.monitorable = false
		
	if mode == 2:
		knife_range.monitoring = false
		knife_range.monitorable = false
		
		attack_range_2.monitoring = false
		attack_range_2.monitorable = false
		
		attack_range_3.monitoring = false
		attack_range_3.monitorable = false
		
		attack_range_4.monitoring = false
		attack_range_4.monitorable = false
		
		ability_3_side.monitoring = false
		ability_3_side.monitorable = false
		
	if mode == 3:
		knife_range.monitoring = false
		knife_range.monitorable = false
		
		attack_range_2.monitoring = false
		attack_range_2.monitorable = false
		
		attack_range_3.monitoring = false
		attack_range_3.monitorable = false
		
		attack_range_4.monitoring = false
		attack_range_4.monitorable = false
		
		ability_3_side.monitoring = true
		ability_3_side.monitorable = true
		
	if mode == 4:
		knife_range.monitoring = false
		knife_range.monitorable = false
		
		attack_range_2.monitoring = true
		attack_range_2.monitorable = true
		
		attack_range_3.monitoring = true
		attack_range_3.monitorable = true
		
		attack_range_4.monitoring = true
		attack_range_4.monitorable = true
		
		ability_3_side.monitoring = false
		ability_3_side.monitorable = false
