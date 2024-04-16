extends CharacterBody2D

var speed = 70 # Скорость передвижения персонажа
@onready var animation_player = $AnimationPlayer

func _physics_process(_delta):
	velocity = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized() * speed
	move_and_slide()
	update_animation()

func update_animation():
	if velocity.length() == 0:
		animation_player.stop()
	else:
		if velocity.y < 0: animation_player.play("Walk_up")
		elif velocity.x < 0: animation_player.play("Walk_left")
		elif velocity.x > 0: animation_player.play("Walk_right")
		else:
			animation_player.play("Walk_down")


func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		print(area.get_parent().name)


func _on_inventory_gui_closed():
	get_tree().paused = false


func _on_inventory_gui_opened():
	get_tree().paused = true
