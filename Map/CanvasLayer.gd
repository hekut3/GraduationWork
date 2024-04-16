extends CanvasLayer

@onready var inventory = $InventoryGui

func _ready():
	inventory.close()

func _input(event):
	if event.is_action_pressed("inventory"):
		if inventory.is_open_inventory:
			inventory.close()
		else:
			inventory.open()
