extends CharacterBody2D

@export var speed: float = 200.0
var velocity_: Vector2 = Vector2.ZERO
var last_key: String = ""
@onready var enemy: CharacterBody2D = get_parent().get_node("Enemy2_0")
@onready var timer2 = get_tree().current_scene.get_node("Timer2")
var in_area = false
var attacking = false

func get_input():
	var direction = Vector2.ZERO

	if $Camera2D/UI/Health_fill.value <= 0:
		get_tree().change_scene_to_file("res://scenes/died_scene.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		last_key = "up"
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_backwards")

	if Input.is_action_pressed("move_down"):
		direction.y += 1
		last_key = "down"
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_forward")

	if Input.is_action_pressed("move_right"):
		direction.x += 1
		last_key = "right"
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_right")

	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		last_key = "left"
		if not attacking:
			$PlayerAnimator.play("Player_animations/Turn_left")

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

	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		match last_key:
			"right":
				if $PlayerAnimator.has_animation("Player_animations/Attack_right"):
					$PlayerAnimator.play("Player_animations/Attack_right")
			"left":
				if $PlayerAnimator.has_animation("Player_animations/Attack_left"):
					$PlayerAnimator.play("Player_animations/Attack_left")
			"up":
				if $PlayerAnimator.has_animation("Player_animations/Attack_left"):
					$PlayerAnimator.play("Player_animations/Attack_left")
			"down":
				if $PlayerAnimator.has_animation("Player_animations/Attack_right"):
					$PlayerAnimator.play("Player_animations/Attack_right")

		if enemy.is_in_group("Goblin") and in_area:
			enemy_take_damage(enemy)

	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
func _physics_process(delta):
	get_input()
	velocity = velocity_
	move_and_slide()

func _ready():
	timer2.start()
	timer2.one_shot = false
	timer2.wait_time = 5.0 
	timer2.connect("timeout", Callable(self, "on_timer_timeout2"))
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$PlayerAnimator.play("Player_animations/Idle_forward")

	$PlayerAnimator.disconnect("animation_finished", Callable(self, "_on_animation_finished"))
	$PlayerAnimator.connect("animation_finished", Callable(self, "_on_animation_finished"))

func enemy_take_damage(target: CharacterBody2D):
	if target.has_method("take_damage"):
		target.take_damage(20)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Goblin"):
		enemy = body
		in_area = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Goblin"):
		in_area = false

func on_timer_timeout2():
	$Camera2D/UI/Health_fill.value += 10

func _on_animation_finished(anim_name: String):
	if (anim_name == "Player_animations/Attack_right" or
		anim_name == "Player_animations/Attack_left" or
		anim_name == "Player_animations/Attack_up" or
		anim_name == "Player_animations/Attack_down"):
		attacking = false
