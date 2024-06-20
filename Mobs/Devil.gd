extends CharacterBody2D

@export var speed: int = 40
@export var limit: float = 0.5
@export var end_point: Marker2D

var chase: bool = false
var health: int = 3
var is_attacking: bool = false
var last_anim_direction: String = ""
var damage_interval: float = 0.5
var attack_timer: Timer

@onready var player = $"../Player"
@onready var animation_player = $AnimationPlayer
@onready var nav_agent = $NavigationAgent2D

var start_position
var end_position

func _ready():
	start_position = position
	end_position = end_point.global_position
	
	attack_timer = Timer.new()
	attack_timer.wait_time = damage_interval
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

func make_path():
	nav_agent.target_position = player.global_position

func change_direction():
	var temp_end = end_position
	end_position = start_position
	start_position = temp_end

func update_velocity():
	if is_attacking:
		velocity = Vector2.ZERO
		return
	var move_direction = (end_position - position)
	if chase:
		move_direction = (player.position - self.position).normalized()
		velocity = move_direction * speed
	else:
		if move_direction.length() < limit:
			change_direction()
		velocity = move_direction.normalized() * speed

func update_animation():
	if is_attacking:
		animation_player.play("attack" + last_anim_direction)
		return
	
	if velocity.length() == 0:
		if animation_player.is_playing():
			animation_player.stop()
	else:
		var direction = ""
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x < 0: direction = "_left"
			elif  velocity.x > 0: direction = "_right"
		else:
			if velocity.y < 0: direction = "_up"
			elif velocity.y > 0: direction = "_down"
		animation_player.play("walk" + direction)
		last_anim_direction = direction

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

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		is_attacking = true
		attack_timer.start()

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		is_attacking = false
		attack_timer.stop()
		
func _on_attack_timer_timeout():
	if is_attacking and player.is_in_group("Player"):
		player.take_damage(1)

