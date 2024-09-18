extends Node2D

@onready var mana_bar = get_node("/root/MainScene/Player/Camera2D/UI/Health_fill/Mana_fill")

func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	# increasing the players mana
	if (area.is_in_group("Player")):
		mana_bar.value += 20
		self.queue_free()
