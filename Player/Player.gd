extends CharacterBody2D

var speed = 70 # Скорость передвижения персонажа
@onready var animation_player = $AnimationPlayer

func _physics_process(_delta):
	velocity = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized() * speed
	move_and_slide()
	
	# Анимация персонажа
	var dir = velocity.normalized()
	if (dir.x < 0 and dir.y < 0) or (dir.x > 0 and dir.y < 0) or dir == Vector2.UP:
		animation_player.play("Walk_up")
	elif (dir.x > 0 and dir.y > 0) or (dir.x < 0 and dir.y > 0) or dir == Vector2.DOWN:
		animation_player.play("Walk_down")
	elif dir == Vector2.LEFT:
		animation_player.play("Walk_left")
	elif dir == Vector2.RIGHT:
		animation_player.play("Walk_right")
	else:
		animation_player.play("Idle")
