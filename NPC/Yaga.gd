extends CharacterBody2D

var is_chatting = false
var player
var player_in_chat_zone = false

func _ready():
	randomize()
	
func _process(_delta):
	$AnimatedSprite2D.play("Idle")
	if Input.is_action_just_pressed("chat"):
		print("chat with npc")
		$Dialogue.start()
		is_chatting = true
	if Input.is_action_just_pressed("quest"):
		print("квест начат")
		$Yaga_quest.next_quest()
		is_chatting = true
	
func _on_chat_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_chat_zone = true


func _on_chat_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_chat_zone = false

func choose(array):
	array.shuffle()
	return array.front()

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1, 1.5])

func _on_dialogue_dialogue_finished():
	is_chatting = false
