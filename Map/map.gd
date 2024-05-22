extends Node2D

@onready var hearts_container = $CanvasLayer/heartsContainer
@onready var player = $TileMap/Player

func _ready():
	hearts_container.set_max_hearts(player.max_health)
	hearts_container.update_hearts(player.current_health)
	player.health_changed.connect(hearts_container.update_hearts)

func _on_inventory_gui_closed():
	get_tree().paused = false

func _on_inventory_gui_opened():
	get_tree().paused = true
