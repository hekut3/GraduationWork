extends CharacterBody2D

var speed = 40
var chase = false
var idle_timer = 10
@onready var animation_player = $AnimationPlayer

func _process(delta):
	var direction = ($"../Player".position - self.position).normalized().x
	if chase:
		position += ($"../Player".position - self.position).normalized() * speed * delta
		update_animation()
	else:
		idle_timer -= delta
		if idle_timer <= 0:
			if direction < 0:
				animation_player.play("Idle_left")
			else:
				animation_player.play("Idle_right")
	move_and_slide()

func update_animation():
	var direction = ($"../Player".position - self.position).normalized()
	if direction.length() == 0:
		animation_player.stop()
	else:
		idle_timer = 10
		if direction.y < 0: animation_player.play("Run_up")
		elif direction.x < 0: animation_player.play("Run_left")
		elif direction.x > 0: animation_player.play("Run_right")
		else:
			animation_player.play("Run_down")

func _on_detector_body_entered(body):
	if body.is_in_group("Player"):
		chase = true
		idle_timer = 10

func _on_detector_body_exited(body):
	if body.is_in_group("Player"):
		chase = false
		animation_player.stop()
