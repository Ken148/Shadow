extends Sprite2D

# Declare variables to hold references to nodes
@onready var options_button = $Options_button
@onready var exit_button = $Exit_button
@onready var start_button = $Start_button

func _ready():
	# Connect signals from the button nodes to their respective methods
	exit_button.connect("pressed", self, "_on_exit_button_pressed")
	start_button.connect("pressed", self, "_on_start_button_pressed")
	options_button.connect("pressed", self, "_on_options_button_pressed")

func _physics_process(delta):
	# Play the 'Idle' animation
	var animation_player = $AnimationPlayer
	if animation_player:
		animation_player.play("Idle")

func _on_exit_button_pressed():
	get_tree().quit()  # Quit the game

func _on_start_button_pressed():
	get_tree().change_scene("res://scenes/main_scene.tscn")  # Change to the main scene

func _on_options_button_pressed():
	get_tree().change_scene("res://scenes/settings.tscn")  # Change to the settings scene
