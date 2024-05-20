extends CharacterBody2D

@export var speed = 40
@export var limit = 0.5
@export var end_point: Marker2D

var idle_timer = 10
var chase = false
var player = null

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
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction = "_down"
		if velocity.x < 0: direction = "_left"
		elif velocity.x > 0: direction = "_right"
		elif velocity.y < 0: direction = "_up"
		
		animations.play("walk" + direction)

func _physics_process(_delta):
	if chase:
		position += (player.position - position) / speed
		
	
		
	update_velocity()
	move_and_slide()
	update_animations()

func _on_detector_body_entered(body):
	player = body
	chase = true

func _on_detector_body_exited(_body):
	player = null
	chase = false
