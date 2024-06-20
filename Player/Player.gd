extends CharacterBody2D

class_name Player

signal  health_changed
signal fly_agaric_collected

@onready var animation_player = $AnimationPlayer
@onready var hurt_timer = $HurtTimer
@onready var hurt_box = $HurtBox
@onready var effects = $Effects
@onready var current_health: int = max_health
@onready var needle_node = $"../Needle"

@export var max_health: int = 3
@export var knockback_power: int = 400
@export var inventory: Inventory

var speed: int = 60
var is_hurt: bool = false
var last_anim_direction: String = "_down"
var is_attacking: bool = false

func _ready():
	inventory.use.connect(use_item)
	effects.play("RESET")

func handle_input():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed
	
	if Input.is_action_just_pressed("attack"):
		attack()
		
func attack():
	is_attacking = true
	animation_player.play("Attack" + last_anim_direction)
	$AreaAttack/CollisionShapeAttack.disabled = false
	await  animation_player.animation_finished
	$AreaAttack/CollisionShapeAttack.disabled = true
	is_attacking = false
	animation_player.stop()
	
func update_animation():
	if is_attacking: return
	
	if velocity.length() == 0:
		if animation_player.is_playing():
			animation_player.stop()
	else:
		var direction = "_down"
		if velocity.y < 0: direction = "_up"
		elif velocity.x < 0: direction = "_left"
		elif velocity.x > 0: direction = "_right"
		animation_player.play("Walk" + direction)
		last_anim_direction = direction

func _physics_process(_delta):
	handle_input()
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
		
	health_changed.emit(current_health)
	is_hurt = true
	knockback(area.get_parent().velocity)
	effects.play("hurtBlink")
	hurt_timer.start()
	await hurt_timer.timeout
	effects.play("RESET")
	is_hurt = false

func _on_hurt_box_area_entered(area):
	if area.has_method("collect"):
		area.collect(inventory)

func knockback(enemyVelocity: Vector2):
	var knockback_direction = (enemyVelocity - velocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()

func _on_hurt_box_area_exited(_area):
	pass

func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(1)
	
	if body.is_in_group("Boss"):
		if needle_node.needle_is_broken:
			body.take_damage(1)
		else: body.take_damage(0)

func take_damage(amount):
	current_health -= amount
	if current_health < 0:
		current_health = max_health
	health_changed.emit(current_health)
	effects.play("hurtBlink")
	hurt_timer.start()
	await hurt_timer.timeout
	effects.play("RESET")
	#if  current_health <= 0:
		#queue_free()

func increase_health(amount: int) -> void:
	current_health += amount
	current_health = min(max_health, current_health)
	
	health_changed.emit(current_health)

func use_item(item: InventoryItem) -> void:
	item.use(self)
