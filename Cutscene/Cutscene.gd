extends Node2D

@onready var cutscene = $Cutscene

func _ready():
	var animation_player = $AnimationPlayer
	cutscene.play()
	animation_player.play("Clouds")
	
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)
	timer.start(40)
	
func _on_timer_timeout():
	get_tree().change_scene_to_file("res://Map/map.tscn")
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://Map/map.tscn")
