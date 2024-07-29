extends Node2D

var speed = 5
var stop_distance = 10
var player_node: Node2D
var enemy_node: Node2D

@onready var animationEnemy = $Body/AnimationEnemy
	
func _ready():
	player_node = get_tree().current_scene.get_node("Player")
	enemy_node = self
	
func _physics_process(delta):
	var player_position = player_node.position
	var enemy_position = enemy_node.position
	var direction = (player_position - enemy_position).normalized()
	var distance = player_position.distance_to(enemy_position)
		
	if distance > stop_distance:
		position += direction * delta * speed
	else:
		position = enemy_position
			
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animationEnemy.play("facing_right")
		else:
			animationEnemy.play("facing_left")
	else:
		if direction.y > 0:
			animationEnemy.play("facing_forwards")
		else:
			animationEnemy.play("facing_backward")

