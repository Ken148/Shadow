extends Sprite2D


func _physics_process(delta):
	$AnimationPlayer.play("Idle")

func _on_exit_button_pressed():
	get_tree().quit()

func _on_start_buton_pressed():
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
