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
	if event.is_action("move_down"):
		position.y+=speed
	if event.is_action("move_right"):
		position.x+=speed
	if event.is_action("move_left"):
		position.x-=speed
