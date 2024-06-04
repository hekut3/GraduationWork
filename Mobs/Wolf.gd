extends CharacterBody2D

var speed = 40
var chase = false
var health = 2
var is_attacking: bool = false
var last_anim_direction: String = "_down"
var attack_pause: float = 0.2

@onready var player = $"../Player"
@onready var animation_player = $AnimationPlayer

func update_velocity():
	var direction = (player.position - self.position)
	if chase:
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO
		animation_player.play("idle_left")

func update_animation():
	if is_attacking: return
	
	else:
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
		chase = true

func _on_detector_body_exited(body):
	if body.is_in_group("Player"):
		chase = false

func take_damage(amount):
	health -= amount
	if  health <= 0:
		animation_player.play("death_left")
		queue_free()

func _on_area_attack_body_entered(body):
	if body.is_in_group("Player"):
		is_attacking = true
		animation_player.play("attack" + last_anim_direction)
		body.take_damage(1)

func _on_area_attack_body_exited(body):
	if body.is_in_group("Player"):
		is_attacking = false
