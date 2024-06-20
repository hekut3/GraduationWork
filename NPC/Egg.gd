extends CharacterBody2D

@onready var needle = $"../Needle"
@onready var animation_player = $AnimationPlayer
@onready var timer = Timer.new()

var health: int = 1

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 0.6
	timer.timeout.connect(_on_timeout)

func take_damage(amount):
	health -= amount
	if  health <= 0:
		animation_player.play("disappearing")
		timer.start()

func _on_timeout():
	queue_free()
	if is_instance_valid(needle):
		needle.position = self.position
