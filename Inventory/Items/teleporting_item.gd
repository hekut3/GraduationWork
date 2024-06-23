class_name TeleportItem extends InventoryItem

var available_positions: Array = []

func use(player: Player) -> void:
	initialize_available_positions()
	
	var random_index = randi() % available_positions.size()
	var random_position = available_positions[random_index]
	
	player.position = random_position
	
func initialize_available_positions():
	available_positions = [
		Vector2(1100, 1450),
		Vector2(1500, 2850),
		Vector2(2200, 350),
		Vector2(2300, 1280),
		Vector2(3850, 1850),
	]
	
