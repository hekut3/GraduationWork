extends Control

signal opened
signal closed

var is_open_inventory: bool = false

@onready var inventory: Inventory = preload("res://Inventory/playerInventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	inventory.updated.connect(update)
	update()

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

func open():
	visible = true
	is_open_inventory = true
	opened.emit()

func close():
	visible = false
	is_open_inventory = false
	closed.emit()
