extends CharacterBody2D

signal  health_changed

var speed = 70 # Скорость передвижения персонажа
@onready var animation_player = $AnimationPlayer

@export var max_health = 3
@onready var current_health: int = max_health

@export var knock_back_power: int = 300

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
		current_health -= 1
		if current_health < 0:
			current_health = max_health
		#print(current_health)
		#print(area.get_parent().name)
		health_changed.emit(current_health)
		knock_back(area.get_parent().velocity)

func knock_back(enemy_velocity: Vector2):
	var knock_back_direction = (enemy_velocity - velocity).normalized() * knock_back_power
	velocity = knock_back_direction
	print(velocity)
	print(position)
	move_and_slide()
	print(" ")

func _on_inventory_gui_closed():
	get_tree().paused = false


func _on_inventory_gui_opened():
	get_tree().paused = true
