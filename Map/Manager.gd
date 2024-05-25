extends Node

@onready var pause_menu = $"../CanvasLayer/PauseMenu"
@onready var player = $"../TileMap/Player"
@onready var hearts_container = $"../CanvasLayer/heartsContainer"

var game_paused: bool = false

var save_path = "user://savegame.save"

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		game_paused = !game_paused
		
	if game_paused == true:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()

func _on_resume_pressed():
	game_paused = !game_paused

func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/menu.tscn")

func _on_save_pressed():
	save_game()
	game_paused = !game_paused

func _on_load_pressed():
	load_game()
	game_paused = !game_paused

func save_game() -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(player.global_position.x)
	file.store_var(player.global_position.y)
	file.store_var(player.current_health)
	file.close()
	
func load_game() -> void:
	var file = FileAccess.open(save_path, FileAccess.READ)
	player.global_position.x = file.get_var(player.global_position.x)
	player.global_position.y = file.get_var(player.global_position.y)
	player.current_health = file.get_var(player.current_health)
	file.close()
	hearts_container.update_hearts(player.current_health)
	
