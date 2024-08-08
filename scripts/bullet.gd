extends Node2D

@export var speed: float = 350.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	if direction != Vector2.ZERO:
		direction = direction.normalized()

func _physics_process(delta):
	position += direction * speed * delta

func _on_area_2d_body_entered(body):
	if body.is_in_group("Goblin"):
		if body.is_inside_tree():
			if body.has_method("take_damage"):
				body.take_damage(20)
		queue_free()
