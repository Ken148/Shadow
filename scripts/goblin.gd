extends Node2D

var speed = 300
var stop_distance = 10
var player_node: Node2D

func _physics_process(delta):
	player_node = get_tree().root.get_node("/root/MainScene/Player")
	if player_node:
		var player_position = player_node.position
		var enemy_position = position
		var direction = (player_position - enemy_position).normalized()
		var distance = player_position.distance_to(enemy_position)
		
		if distance > stop_distance:
			position += direction * delta * speed
