extends Sprite2D

func _process(delta):
	var animation_player = $AnimationPlayer
	if animation_player:
		animation_player.play("Idle")

func _on_exit_button_pressed():
	get_tree().quit() 

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn") 

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
