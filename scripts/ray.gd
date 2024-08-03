extends RayCast2D

@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")
var player_position: Vector2

func _ready():
	pass

func _process(delta):
	if is_colliding():
		pass
		
	if player:
		player_position = player.position
		queue_redraw()

func _draw():
	if player:
		draw_line(Vector2(0, 0), player_position - position, Color.RED, 1.0)
