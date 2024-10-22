extends Sprite2D

func _process(delta):
	# player idle animation at start
	var animation_player = $AnimationPlayer
	if animation_player:
		animation_player.play("Idle")

func _on_exit_button_pressed():
	# close game
	get_tree().quit() 

func _on_options_button_pressed():
	# open settings menu
	get_tree().change_scene_to_file("res://scenes/settings.tscn") 

func _on_start_button_pressed():
	# changing to main_scene
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
