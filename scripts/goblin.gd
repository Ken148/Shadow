extends Node2D

var speed = 5
var stop_distance = 10
var player_node: Node2D
var enemy_node: Node2D
@onready var timer = get_tree().current_scene.get_node("Timer")

func _ready():
	player_node = get_tree().current_scene.get_node("Player")
	enemy_node = self
	timer.one_shot = false
	timer.wait_time = 2.0 
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	connect("body_entered", Callable(self, "_on_area_2d_body_entered"))
	connect("body_exited", Callable(self, "_on_area_2d_area_shape_exited"))

func _physics_process(delta):
	var player_position = player_node.position
	var enemy_position = enemy_node.position
	var direction = (player_position - enemy_position).normalized()
	var distance = player_position.distance_to(enemy_position)
	
	if distance > stop_distance:
		position += direction * delta * speed
	else:
		position = enemy_position

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		_on_Timer_timeout() 

func _on_Timer_timeout():
	if player_node.is_in_group("Player"):
		var hp = get_tree().current_scene.get_node("Player/Camera2D/UI/Health_fill")
		hp.value -= 10
		timer.start() 

func _on_area_2d_area_shape_exited(body):
	print("beans")
	if body.is_in_group("Player"): 
		timer.stop() 
