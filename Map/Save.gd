extends Resource

const SAVE_GAME := "user://save_invent.save"

@export var inventory: Resource = preload("res://Inventory/playerInventory.tres")

func write_save() -> void:
	ResourceSaver.save(inventory, "user://save_invent.save")

static func load_save() -> Resource:
	if ResourceLoader.exists(SAVE_GAME):
		return load(SAVE_GAME)
	return null
