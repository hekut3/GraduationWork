extends CharacterBody2D

@export var speed: int = 40

var chase: bool = false
var health: int = 2
var is_attacking: bool = false
var last_anim_direction: String = ""
var damage_interval: float = 0.7
var attack_timer: Timer

@onready var player = $"../Player"
@onready var animation_player = $AnimationPlayer
@onready var nav_agent = $NavigationAgent2D

func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = damage_interval
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

func make_path():
	nav_agent.target_position = player.global_position

func update_velocity():
	if is_attacking:
		velocity = Vector2.ZERO
		return
	var direction = (player.position - self.position)
	if chase:
		velocity = direction.normalized() * speed

func update_animation():
	if is_attacking:
		animation_player.play("attack" + last_anim_direction)
		return
	if chase:
		var direction = ""
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x < 0: direction = "_left"
			elif  velocity.x > 0: direction = "_right"
		else:
			if velocity.y < 0: direction = "_up"
			elif velocity.y > 0: direction = "_down"
		animation_player.play("run" + direction)
		last_anim_direction = direction
	else:
		if velocity.x < 0: animation_player.play("idle_left")
		elif velocity.x > 0: animation_player.play("idle_right")
		velocity = Vector2.ZERO

func _physics_process(_delta):
	make_path()
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
		queue_free()

func _on_area_attack_body_entered(body):
	if body.is_in_group("Player"):
		is_attacking = true
		attack_timer.start()

func _on_area_attack_body_exited(body):
	if body.is_in_group("Player"):
		is_attacking = false
		attack_timer.stop()

func _on_attack_timer_timeout():
	if is_attacking and player.is_in_group("Player"):
		player.take_damage(1)
		
