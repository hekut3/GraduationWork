extends Node2D

@onready var mainMenuTheme = $"Main Menu Theme"

func _ready():
	mainMenuTheme.play()

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://Cutscene/Cutscene.tscn")

func _on_quit_pressed():
	get_tree().quit()

