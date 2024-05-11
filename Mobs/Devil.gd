extends CharacterBody2D

@export var speed = 20
@export var limit = 0.5
@export var end_point: Marker2D

@onready var animations = $AnimationPlayer

var start_position
var end_position

func _ready():
	start_position = position
	end_position = end_point.global_position

func change_direction():
	var temp_end = end_position
	end_position = start_position
	start_position = temp_end

func update_velocity():
	var move_direction = (end_position - position)
	if move_direction.length() < limit:
		change_direction()
	velocity = move_direction.normalized() * speed

func update_animations():
	var animation_string = "walk_up"
	if velocity.y > 0:
		animation_string = "walk_down"
	animations.play(animation_string)

func _physics_process(delta):
	update_velocity()
	move_and_slide()
	update_animations()
