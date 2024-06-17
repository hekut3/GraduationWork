extends CharacterBody2D

@export var speed = 30

var chase_by_player = false
var health = 1
var last_anim_direction: String = ""

@onready var player = $"../Player"
@onready var animation_player = $AnimationPlayer

func update_velocity():
	if chase_by_player:
		var direction = (self.position - player.position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		
func update_animation():
	if chase_by_player:
		var direction = ""
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x < 0: direction = "_left"
			elif  velocity.x > 0: direction = "_right"
		else:
			if velocity.y < 0: direction = "_up"
			elif velocity.y > 0: direction = "_down"
		animation_player.play("run" + direction)
		last_anim_direction = direction
		
func _physics_process(_delta):
	update_velocity()
	move_and_slide()
	update_animation()

func _on_detector_body_entered(body):
	if body.is_in_group("Player"):
		chase_by_player = true

func _on_detector_body_exited(body):
	if body.is_in_group("Player"):
		chase_by_player = false

func take_damage(amount):
	health -= amount
	if  health <= 0:
		queue_free()
