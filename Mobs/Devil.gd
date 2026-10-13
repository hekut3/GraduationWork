extends CharacterBody2D

@export var speed: int = 40
@export var patrol_distance: float = 100.0
@export var limit: float = 2.0
@export var repath_interval: float = 0.25  # как часто пересчитывать путь к игроку

var chase_by_player: bool = false
var health: int = 3
var is_attacking: bool = false
var last_anim_direction: String = ""
var is_dead: bool = false

var damage_interval: float = 0.5
var attack_timer: Timer

@onready var player = $"../Player"
@onready var animation_player = $AnimationPlayer
@onready var agent: NavigationAgent2D = $NavigationAgent2D

var start_position: Vector2
var direction: int = 1
var _repath_timer: float = 0.0

func _ready():
	start_position = global_position

	attack_timer = Timer.new()
	attack_timer.wait_time = damage_interval
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

	animation_player.animation_finished.connect(_on_animation_finished)

	# Ждём один физический кадр, чтобы навигационная карта успела построиться
	await get_tree().physics_frame


func update_velocity(delta: float) -> void:
	if is_attacking:
		velocity = Vector2.ZERO
		return

	if chase_by_player:
		# Пересчитываем цель по таймеру, а не каждый кадр
		_repath_timer -= delta
		if _repath_timer <= 0.0:
			_repath_timer = repath_interval
			agent.target_position = player.global_position

		# Путь закончился (дошли до цели или пути нет) — стоим
		if agent.is_navigation_finished():
			velocity = Vector2.ZERO
			return

		# Берём следующую точку пути и идём к ней
		var next_point := agent.get_next_path_position()
		velocity = (next_point - global_position).normalized() * speed
	else:
		# Патруль влево-вправо — оставляем как было
		var target_x = start_position.x + patrol_distance * direction
		if abs(global_position.x - target_x) < limit:
			direction *= -1
		velocity = Vector2(direction * speed, 0)


func update_animation():
	if is_attacking:
		animation_player.play("attack" + last_anim_direction)
		return

	if velocity.length() == 0:
		animation_player.stop()
		return

	var anim_dir := ""
	if velocity.x < 0:
		anim_dir = "_left"
	elif velocity.x > 0:
		anim_dir = "_right"

	animation_player.play("walk" + anim_dir)
	last_anim_direction = anim_dir


func _physics_process(delta):
	if is_dead:
		return

	update_velocity(delta)
	move_and_slide()
	update_animation()


# --- остальные функции без изменений ---

func _on_detector_body_entered(body):
	if body.is_in_group("Player"):
		chase_by_player = true


func _on_detector_body_exited(body):
	if body.is_in_group("Player"):
		chase_by_player = false


func take_damage(amount):
	if is_dead:
		return

	health -= amount
	print(health)

	if health <= 0:
		is_dead = true
		chase_by_player = false
		is_attacking = false
		velocity = Vector2.ZERO
		attack_timer.stop()
		animation_player.play("disappearing")


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		is_attacking = true
		attack_timer.start()


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		is_attacking = false
		attack_timer.stop()


func _on_attack_timer_timeout():
	if is_attacking:
		player.take_damage(1)


func _on_animation_finished(anim_name: String):
	if anim_name == "disappearing":
		queue_free()
