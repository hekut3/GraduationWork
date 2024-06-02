extends CharacterBody2D

@export var speed = 40
@export var limit = 0.5
@export var end_point: Marker2D

var idle_timer = 10
var chase = false
var player = null
var health = 3

@onready var animation_player = $AnimationPlayer

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

func update_animation():
	if velocity.length() == 0:
		if animation_player.is_playing():
			animation_player.stop()
	else:
		var direction = "_down"
		if velocity.x < 0: direction = "_left"
		elif velocity.x > 0: direction = "_right"
		elif velocity.y < 0: direction = "_up"
		
		animation_player.play("walk" + direction)

func _physics_process(delta):
	if chase:
		position += ($"../Player".position - self.position).normalized() * speed * delta
		
	update_velocity()
	move_and_slide()
	update_animation()

func _on_detector_body_entered(body):
	if body.is_in_group("Player"):
		chase = true

func _on_detector_body_exited(body):
	if body.is_in_group("Player"):
		chase = false

func take_damage(amount):
	health -= amount
	if  health <= 0:
		#animation_player.play("Death_left")
		queue_free()
