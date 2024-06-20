extends CharacterBody2D

var player_in_use_zone: bool = false

@export var needle_is_broken: bool = false

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("idle")
	animation_player.animation_finished.connect(_on_animation_finished)

func _process(_delta):
	if Input.is_action_just_pressed("interaction") and player_in_use_zone:
		animation_player.play("disappearing")
		needle_is_broken = true

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_use_zone = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_use_zone = false

func _on_animation_finished(anim_name: String):
	if anim_name == "disappearing":
		animation_player.play("broken_needle")
