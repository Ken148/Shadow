extends Node2D

var speed = 5
var stop_distance = 10
var player_node: Node2D

func _ready():
	var animation = $Body/AnimationPlayer
	
func _physics_process(delta):
	var animation = $Body/AnimationPlayer
	player_node = get_tree().root.get_node("/root/MainScene/Player")
	if player_node:
		var player_position = player_node.position
		var enemy_position = position
		var direction = (player_position - enemy_position).normalized()
		var distance = player_position.distance_to(enemy_position)
		
		if distance > stop_distance:
			position += direction * delta * speed
		else:
			position = enemy_position
			
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				animation.play("facing_right")
			else:
				animation.play("facing_left")
		else:
			if direction.y > 0:
				animation.play("facing_forwards")
			else:
				animation.play("facing_backward")

