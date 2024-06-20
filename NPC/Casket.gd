extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var hare = $"../Hare"
@onready var koschey = $"../Koschey"

var player_in_use_zone: bool = false

func _ready():
	animation_player.play("casket_closed")
	
func _process(_delta):
	if Input.is_action_just_pressed("interaction") and player_in_use_zone:
		animation_player.play("casket_open")
		if is_instance_valid(hare) and is_instance_valid(koschey):
			hare.position = self.position
			koschey.position = Vector2(888, 1250)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_use_zone = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_use_zone = false
