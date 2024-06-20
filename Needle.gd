extends CharacterBody2D

var player_in_use_zone: bool = false

@export var needle_is_broken: bool = false

@onready var animation_player = $AnimationPlayer
@onready var timer = Timer.new()

func _ready():
	animation_player.play("idle")
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 0.6
	timer.timeout.connect(_on_timeout)

func _process(_delta):
	if Input.is_action_just_pressed("interaction") and player_in_use_zone:
		animation_player.play("disappearing")
		timer.start()
		needle_is_broken = true

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_use_zone = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_use_zone = false

func _on_timeout():
	animation_player.play("broken_needle")
