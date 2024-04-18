extends CharacterBody2D

signal  health_changed

var speed = 70 # Скорость передвижения персонажа
@onready var animation_player = $AnimationPlayer
@onready var hurt_timer = $HurtTimer
@onready var hurt_box = $HurtBox
@export var max_health = 3
@onready var current_health: int = max_health

@export var knock_back_power: int = 300

var is_hurt: bool = false

func _physics_process(_delta):
	velocity = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized() * speed
	move_and_slide()
	update_animation()
	if !is_hurt:
		for area in hurt_box.get_overlapping_areas():
			if area.name == "HitBox":
				hurt_by_enemy(area)

func hurt_by_enemy(area):
	current_health -= 1
	if current_health < 0:
		current_health = max_health
	#print(current_health)
	print(area.get_parent().name)
	health_changed.emit(current_health)
	is_hurt = true
	knock_back(area.get_parent().velocity)
	hurt_timer.start()
	await hurt_timer.timeout
	is_hurt = false

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
	if area.has_method("collect"):
		area.collect()

func knock_back(enemy_velocity: Vector2):
	var knock_back_direction = (enemy_velocity - velocity).normalized() * knock_back_power
	velocity = knock_back_direction
	move_and_slide()

func _on_inventory_gui_closed():
	get_tree().paused = false


func _on_inventory_gui_opened():
	get_tree().paused = true


func _on_hurt_box_area_exited(area): pass
