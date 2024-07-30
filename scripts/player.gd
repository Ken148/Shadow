extends CharacterBody2D

@export var speed: float = 200.0
var velocity_: Vector2 = Vector2.ZERO
var last_key: String = ""
@onready var enemy: CharacterBody2D = get_parent().get_node("Enemy2_0")
@onready var timer2 = get_tree().current_scene.get_node("Timer2")

func get_input():
	var direction = Vector2.ZERO

	if $Camera2D/UI/Health_fill.value <= 0:
		get_tree().change_scene_to_file("res://scenes/died_scene.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		last_key = "up"
		$PlayerAnimator.play("Player_animations/Turn_backwards")

	if Input.is_action_just_pressed("attack"):
		if enemy:
			if enemy.is_in_group("Goblin"):
				enemy_take_damage(enemy) 

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

	if direction.length() == 0:
		match last_key:
			"right":
				$PlayerAnimator.play("Player_animations/Idle_right")
			"left":
				$PlayerAnimator.play("Player_animations/Idle_left")
			"up":
				$PlayerAnimator.play("Player_animations/Idle_backward")
			"down":
				$PlayerAnimator.play("Player_animations/Idle_forward")

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

func enemy_take_damage(target: CharacterBody2D):
	if target.has_method("take_damage"):
		target.take_damage(20)
		
func _on_area_2d_body_entered(body):
	if(body.is_in_group("Goblin")):
		enemy = body

func on_timer_timeout2():
	$Camera2D/UI/Health_fill.value += 10
