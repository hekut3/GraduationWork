extends CharacterBody2D

@export var speed: int = 50

var chase_by_player: bool = false
var health: int = 1
var last_anim_direction: String = ""

@onready var player = $"../Player"
@onready var animation_player = $AnimationPlayer
@onready var egg = $"../Egg"
@onready var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 0.6
	timer.timeout.connect(_on_timeout)

func update_velocity():
	if chase_by_player:
		var direction = (self.position - player.position).normalized()
		velocity = direction * speed
		
func update_animation():
	if chase_by_player:
		var direction = ""
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x < 0: direction = "_left"
			elif  velocity.x > 0: direction = "_right"
		else:
			if velocity.y < 0: direction = "_up"
			elif velocity.y > 0: direction = "_down"
		animation_player.play("flight" + direction)
		last_anim_direction = direction
	else:
		if velocity.x < 0: animation_player.play("idle_left")
		elif velocity.x > 0: animation_player.play("idle_right")
		velocity = Vector2.ZERO
		
func _physics_process(_delta):
	update_velocity()
	move_and_slide()
	update_animation()

func _on_detector_body_entered(body):
	if body.is_in_group("Player"):
		chase_by_player = true

func _on_detector_body_exited(body):
	if body.is_in_group("Player"):
		chase_by_player = false

func take_damage(amount):
	health -= amount
	if  health <= 0:
		chase_by_player = false
		velocity = Vector2.ZERO
		animation_player.play("disappearing")
		timer.start()

func _on_timeout():
	queue_free()
	if is_instance_valid(egg):
		egg.position = self.position
