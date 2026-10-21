extends CharacterBody2D

@export var speed: int = 40
@export var patrol_distance: float = 100.0
@export var limit: float = 2.0
@export var repath_interval: float = 0.25

var chase_by_player: bool = false
var health: int = 3
var is_attacking: bool = false
var last_anim_direction: String = "_right" 
var is_dead: bool = false

var damage_interval: float = 0.5
var attack_timer: Timer

@onready var player = $"../Player"
@onready var animation_player = $AnimationPlayer
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var line_of_sight: RayCast2D = $LineOfSight 

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
	await get_tree().physics_frame


func _physics_process(delta):
	if is_dead:
		return

	_update_vision()
	update_velocity(delta)
	move_and_slide()
	
	if not chase_by_player and get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if abs(collision.get_normal().x) > 0.5:
				direction *= -1
				break

	update_animation()


# Проверка прямой видимости
func _update_vision():
	# Если мертв или атакует — не проверяем
	if is_dead or is_attacking:
		return
		
	# Если игрок вообще не в зоне детектора, то и видеть его не можем
	if not _is_player_in_detector():
		chase_by_player = false
		return

	# Направляем луч от врага к игроку
	line_of_sight.target_position = to_local(player.global_position)
	line_of_sight.force_raycast_update()

	# Если луч во что-то уперся (и это не сам игрок) — значит, мы не видим его
	if line_of_sight.is_colliding():
		var collider = line_of_sight.get_collider()
		if collider != player:
			chase_by_player = false # Игрок за стеной, теряем его
			return

	# Если луч чист, видим игрока
	chase_by_player = true


# Вспомогательная функция: проверяем, находится ли игрок в Area2D "Detector"
func _is_player_in_detector() -> bool:
	var detector = get_node_or_null("Detector")
	if detector:
		return detector.overlaps_body(player)
	return false


func update_velocity(delta: float) -> void:
	if is_attacking:
		velocity = Vector2.ZERO
		return

	if chase_by_player:
		_repath_timer -= delta
		if _repath_timer <= 0.0:
			_repath_timer = repath_interval
			agent.target_position = player.global_position

		if agent.is_navigation_finished():
			# Защита: если путь закончен, но до игрока далеко — значит, путь не проложился
			# (например, игрок стоит на недоступном тайле). Сбрасываем погоню.
			if global_position.distance_to(player.global_position) > 50.0:
				chase_by_player = false
			velocity = Vector2.ZERO
			return

		var next_point := agent.get_next_path_position()
		var to_next := next_point - global_position
		
		var desired_vel = to_next.normalized() * speed
		velocity = velocity.lerp(desired_vel, 0.3)
		
		if to_next.length() < 4.0:
			velocity = velocity.lerp(Vector2.ZERO, 0.5)
	else:
		var target_x = start_position.x + patrol_distance * direction
		if abs(global_position.x - target_x) < limit:
			direction *= -1
		velocity.x = direction * speed
		velocity.y = 0


func update_animation():
	if is_attacking:
		var attack_anim = "attack" + last_anim_direction
		if animation_player.current_animation != attack_anim:
			animation_player.play(attack_anim)
		return

	var real_vel = get_real_velocity()
	
	if real_vel.length() < 5.0:
		if animation_player.is_playing():
			animation_player.stop()
		return

	var anim_dir := ""
	if real_vel.x < 0:
		anim_dir = "_left"
	elif real_vel.x > 0:
		anim_dir = "_right"

	if anim_dir != "":
		var walk_anim = "walk" + anim_dir
		if animation_player.current_animation != walk_anim:
			animation_player.play(walk_anim)
			last_anim_direction = anim_dir


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
