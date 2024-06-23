extends CharacterBody2D

@export var first_dialogue: bool = true

@onready var animation_sprite = $AnimatedSprite2D
@onready var dialogue_node = $Dialogue

var is_chatting = false
var player_in_chat_zone = false

func _process(_delta):
	animation_sprite.play("Idle")
	if Input.is_action_just_pressed("interaction") and player_in_chat_zone and not is_chatting:
		if first_dialogue:
			first_dialogue = false
			start_chat("Margarita", 1)
		else:
			var dialogues = [2, 3, 4, 5, 6, 7, 8]
			var random_dialogue = dialogues[int(randf() * dialogues.size())]
			start_chat("Margarita", random_dialogue)
			
func start_chat(npc_name, dialogue_id):
	dialogue_node.start(npc_name, dialogue_id)
	is_chatting = true
	
func _on_chat_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_chat_zone = true

func _on_chat_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_chat_zone = false

func _on_dialogue_dialogue_finished():
	is_chatting = false
