extends CharacterBody2D

@export var first_dialogue: bool = true
@export var second_dialogue: bool = true
@export var third_dialogue: bool = true

@onready var needle_node = $"../Needle"
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
		if first_dialogue:
			first_dialogue = false
			start_chat("Yaga", 1)
		elif second_dialogue:
			second_dialogue = false
			start_chat("Yaga", 2)
		elif third_dialogue:
			third_dialogue = false
			start_chat("Yaga", 3)
		elif needle_node.needle_is_broken:
			start_chat("Yaga", 4)
		else:
			var dialogues = [5, 6, 7, 8]
			var random_dialogue = dialogues[int(randf() * dialogues.size())]
			start_chat("Yaga", random_dialogue)

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
