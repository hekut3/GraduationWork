extends CharacterBody2D

signal  health_changed

var speed = 60 # Скорость передвижения персонажа
@onready var animation_player = $AnimationPlayer
@onready var hurt_timer = $HurtTimer
@onready var hurt_box = $HurtBox
@onready var effects = $Effects

@export var max_health = 3
@onready var current_health: int = max_health

@export var knockbackPower: int = 400

@export var inventory: Inventory

var isHurt: bool = false
var lastAnimDirection: String = "Down"

func _ready():
	effects.play("RESET")

func handleInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed

func updateAnimation():
	if velocity.length() == 0:
		if animation_player.is_playing():
			animation_player.stop()
	else:
		if velocity.y < 0: animation_player.play("Walk_up")
		elif velocity.x < 0: animation_player.play("Walk_left")
		elif velocity.x > 0: animation_player.play("Walk_right")
		else:
			animation_player.play("Walk_down")

func _physics_process(_delta):
	handleInput()
	move_and_slide()
	updateAnimation()
	if !isHurt:
		for area in hurt_box.get_overlapping_areas():
			if area.name == "HitBox":
				hurtByEnemy(area)

func hurtByEnemy(area):
	current_health -= 1
	if current_health < 0:
		current_health = max_health
		
	health_changed.emit(current_health)
	isHurt = true
	knockback(area.get_parent().velocity)
	effects.play("hurtBlink")
	hurt_timer.start()
	await hurt_timer.timeout
	effects.play("RESET")
	isHurt = false

func _on_hurt_box_area_entered(area):
	if area.has_method("collect"):
		area.collect(inventory)

func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity - velocity).normalized() * knockbackPower
	velocity = knockbackDirection
	move_and_slide()

func _on_inventory_gui_closed():
	get_tree().paused = false

func _on_inventory_gui_opened():
	get_tree().paused = true

func _on_hurt_box_area_exited(area):
	pass
