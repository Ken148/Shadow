extends CharacterBody2D

var speed=10
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action("move_up"):
		position.y-=speed
		$Sprite2D/EnemyAnimation.play("Turn_backwards")
	if event.is_action("move_down"):
		position.y+=speed
		$Sprite2D/EnemyAnimation.play("Turn_forward")
	if event.is_action("move_right"):
		position.x+=speed
		$Sprite2D/EnemyAnimation.play("Turn_right")
	if event.is_action("move_left"):
		position.x-=speed
		$Sprite2D/EnemyAnimation.play("Turn_left")
