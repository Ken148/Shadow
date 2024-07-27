extends Node2D

var speed = 5
var stop_distance = 10
var player_node: Node2D
var enemy_node: Node2D
@onready var enemy_body_node = $Body
@onready var AnimationEnemy = enemy_body_node.get_node("AnimationEnemy")

func _ready():
	pass
	
func _physics_process(delta):
	player_node = get_tree().root.get_node("/root/MainScene/Player")
	enemy_node = get_tree().root.get_node("/root/MainScene/Enemy/Body")
	
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
			AnimationEnemy.play("facing_right")
		else:
			AnimationEnemy.play("facing_left")
	else:
		if direction.y > 0:
			AnimationEnemy.play("facing_forwards")
		else:
			AnimationEnemy.play("facing_backward")

