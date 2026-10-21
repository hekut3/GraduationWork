extends CharacterBody2D

@export var speed: int = 40

var chase: bool = false
var health: int = 2
var is_attacking: bool = false
var is_dead: bool = false 
var last_anim_direction: String = "_left" # Направление для атаки/бега
var last_idle_direction: String = "_left" # Направление для покоя/смерти (только left/right)
var damage_interval: float = 0.7
var attack_timer: Timer

@onready var player = $"../Player"
@onready var animation_player = $AnimationPlayer
@onready var nav_agent = $NavigationAgent2D
@onready var line_of_sight: RayCast2D = $LineOfSight 

func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = damage_interval
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	
	animation_player.animation_finished.connect(_on_death_animation_finished)
	
	await get_tree().physics_frame

func make_path():
	if player:
		nav_agent.target_position = player.global_position

func update_velocity():
	if is_dead or is_attacking:
		velocity = Vector2.ZERO
		return

	if chase:
		if nav_agent.is_navigation_finished():
			velocity = Vector2.ZERO
			return

		var next_point = nav_agent.get_next_path_position()
		var direction = (next_point - global_position).normalized()
		
		var desired_velocity = direction * speed
		velocity = velocity.lerp(desired_velocity, 0.3)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 2.0)


func update_animation():
	if is_dead:
		return 

	if is_attacking:
		var anim = "attack" + last_anim_direction
		if animation_player.current_animation != anim and animation_player.has_animation(anim):
			animation_player.play(anim)
		return
		
	if velocity.length() > 5.0:
		var direction = ""
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x < 0: direction = "_left"
			elif velocity.x > 0: direction = "_right"
		else:
			if velocity.y < 0: direction = "_up"
			elif velocity.y > 0: direction = "_down"
			
		var anim = "run" + direction
		if animation_player.current_animation != anim and animation_player.has_animation(anim):
			animation_player.play(anim)
			last_anim_direction = direction
			
			# Запоминаем горизонтальное направление для покоя и смерти
			if direction == "_left" or direction == "_right":
				last_idle_direction = direction
				
	else:
		# Анимация покоя (использует только left/right)
		var anim = "idle" + last_idle_direction
		if animation_player.current_animation != anim and animation_player.has_animation(anim):
			animation_player.play(anim)


func _physics_process(_delta):
	if is_dead:
		return

	_update_vision()
	make_path()
	update_velocity()
	move_and_slide()
	update_animation()


func _update_vision():
	if is_attacking:
		return
		
	if player == null:
		chase = false
		return

	var detector = get_node_or_null("Detector")
	if detector and not detector.overlaps_body(player):
		chase = false
		return

	line_of_sight.target_position = to_local(player.global_position)
	line_of_sight.force_raycast_update()

	if line_of_sight.is_colliding():
		var collider = line_of_sight.get_collider()
		if collider != player:
			chase = false 
			return

	chase = true


func _on_detector_body_entered(body):
	if body.is_in_group("Player") and not is_dead:
		pass 

func _on_detector_body_exited(body):
	if body.is_in_group("Player"):
		chase = false


func take_damage(amount):
	if is_dead: return
	
	health -= amount
	print(health)
	
	if health <= 0:
		is_dead = true
		chase = false
		is_attacking = false
		velocity = Vector2.ZERO
		attack_timer.stop()
		
		# Выбираем анимацию на основе последнего направления
		var death_anim = "death" + last_idle_direction
		
		if animation_player.has_animation(death_anim):
			animation_player.play(death_anim)
		else:
			animation_player.play("death_left")


func _on_area_attack_body_entered(body):
	if body.is_in_group("Player") and not is_dead:
		is_attacking = true
		attack_timer.start()


func _on_area_attack_body_exited(body):
	if body.is_in_group("Player"):
		is_attacking = false
		attack_timer.stop()


func _on_attack_timer_timeout():
	if is_attacking and player.is_in_group("Player") and not is_dead:
		player.take_damage(1)


func _on_death_animation_finished(anim_name: String):
	if anim_name.begins_with("death"):
		queue_free()
