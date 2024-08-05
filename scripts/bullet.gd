extends Node2D

@export var speed: float = 350.0
@onready var enemy: CharacterBody2D
var direction: Vector2 = Vector2.ZERO

func _ready():
	if direction != Vector2.ZERO:
		direction = direction.normalized()

func _physics_process(delta):
	position += direction * speed * delta

func _on_area_2d_body_entered(body):
	if body.is_in_group("Goblin"):
		enemy = body
		enemy_take_damage(enemy)
		self.queue_free()

func enemy_take_damage(target: CharacterBody2D):
	if target.has_method("take_damage"):
		target.take_damage(20)
