extends HSlider

var brightness: float
@onready var tilemap = get_tree().get_node("MainScene/TileMap")
@onready var slider = self

func _ready():
	var sens = get_tree().get_first_node_in_group("Main_scene/Player")

func _physics_process(delta):
	brightness = slider.value
	tilemap.modulate = Color(brightness, brightness, brightness) 
