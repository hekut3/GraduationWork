extends CharacterBody2D

@onready var animation_sprite = $AnimatedSprite2D
@onready var dialogue_node = $Dialogue
@onready var timer = $Timer

var is_chatting = false
var player_in_chat_zone = false

func _ready():
	randomize()
	
func _process(_delta):
	animation_sprite.play("Idle")
	if Input.is_action_just_pressed("interaction") and player_in_chat_zone and not is_chatting:
		start_chat("Yaga", 1)

func start_chat(npc_name, dialogue_id):
	dialogue_node.start(npc_name, dialogue_id)
	is_chatting = true

func _on_chat_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_chat_zone = true

func _on_chat_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_chat_zone = false

func choose(array):
	array.shuffle()
	return array[0]

func _on_timer_timeout():
	timer.wait_time = choose([0.5, 1, 1.5])

func _on_dialogue_dialogue_finished():
	is_chatting = false
