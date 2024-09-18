extends CharacterBody2D

@export var speed: float = 5.0
@export var enemy_hp: float = 100.0
var player_position: Vector2
@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")
@onready var timer = get_tree().current_scene.get_node("Timer")
@onready var hp_bar_enemy = get_node("ProgressBar")
var can_be_seen = false
var is_in_area = false

func _ready():
	# conneting timer
	timer.start()
	timer.one_shot = false
	timer.wait_time = 2.0 
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _physics_process(delta):
	# making the enemy walk towards player 
	if player.is_in_group("Player") and can_be_seen:
		player_position = player.position
		var direction = (player_position - position).normalized()
		
		if position.distance_to(player_position) > 30:
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
	
	if velocity != Vector2.ZERO:
		move_and_slide()

func _on_Timer_timeout():
	# player can block the enemy if hold RMB
	if is_in_area and !Input.is_action_pressed("block"):
		var player_hp = player.get_node("Camera2D/UI/Health_fill")
		player_hp.value -= 20

func take_damage(damage: int):
	# enemy taking damage
	enemy_hp -= damage
	hp_bar_enemy.value = max(0, enemy_hp)
	
	if enemy_hp <= 0:
		enemy_die()

func enemy_die():
	# stopping timer and removing enemy after death
	timer.stop()
	queue_free()

# checking if player in range
func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		is_in_area = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		is_in_area = false
		
# making the player be behind or infront depending on the position 
func _on_area_2d_3_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area != null and area.is_in_group("player_col"):
		player.z_index = 2

func _on_area_2d_3_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area != null and area.is_in_group("player_col"):
		player.z_index = 3

# checking if the enemy should walk towards the player
func _on_can_be_seen_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area != null and area.is_in_group("Player"):
		can_be_seen = true

func _on_can_be_seen_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area != null and area.is_in_group("Player"):
		can_be_seen = false
