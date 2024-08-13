extends Node2D

@export var speed: float = 5.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	if direction != Vector2.ZERO:
		direction = direction.normalized()

func _physics_process(delta):
	position += direction * speed * delta

func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group("Goblin"): 
		var parent = area.get_parent()
		if parent.has_method("take_damage"):
			parent.take_damage(20)
		queue_free()
