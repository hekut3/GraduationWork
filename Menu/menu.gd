extends Node2D

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://Map/map.tscn")

func _on_quit_pressed():
	get_tree().quit()


func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Cutscene/Cutscene.tscn")
