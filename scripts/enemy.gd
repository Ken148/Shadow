extends CharacterBody2D

@export var speed: float = 100.0
@export var enemy_hp: float = 100.0
var player_position: Vector2
@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")
@onready var timer = get_tree().current_scene.get_node("Timer")
@onready var hp_bar_enemy = get_node("ProgressBar")
@onready var area: Area2D = $Area2D
var can_be_seen
var is_in_area = false

func _ready():
	var attacking_player = player.attacking
	timer.start()
	timer.one_shot = false
	timer.wait_time = 2.0 
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	area.connect("body_entered", Callable(self, "_on_area_body_entered"))
	area.connect("body_exited", Callable(self, "_on_area_body_exited"))

func _physics_process(delta):
	if(player.is_in_group("Player") and can_be_seen):
		player_position = player.position
		var direction = (player_position - position).normalized()

		if position.distance_to(player_position) > 80:
			velocity = direction * speed
			move_and_slide()
	if (player.is_in_group("Player") and can_be_seen == false):
		velocity = Vector2.ZERO

func _on_Timer_timeout():
		var player_hp = get_tree().current_scene.get_node("Player/Camera2D/UI/Health_fill")
		if(is_in_area):
			if(!Input.is_action_pressed("block")):
				player_hp.value -= 20

func take_damage(damage : int):
	enemy_hp -= damage
	hp_bar_enemy.value -= damage
	if(enemy_hp <= 0):
		self.queue_free()

func _on_area_2d_2_body_entered(body):
	if(body.is_in_group("Player")):
		can_be_seen = true

func _on_area_2d_2_body_exited(body):
	if(body.is_in_group("Player")):
		can_be_seen = false

func _on_area_2d_body_entered(body):
	if (body.is_in_group("Player")):
		is_in_area = true

func _on_area_2d_body_exited(body):
	if (body.is_in_group("Player")):
		is_in_area = false
