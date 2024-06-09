extends Button

@onready var container: CenterContainer = $CenterContainer
@onready var inventory = preload("res://Inventory/playerInventory.tres")

var item_stack_gui: ItemStackGui
var index: int

func insert(isg: ItemStackGui):
	item_stack_gui = isg
	container.add_child(item_stack_gui)
	
	if !item_stack_gui.inventory_slot || inventory.slots[index] == item_stack_gui.inventory_slot:
		return
	
	inventory.insert_slot(index, item_stack_gui.inventory_slot)

func take_item():
	var item = item_stack_gui
	
	inventory.remove_slot(item_stack_gui.inventory_slot)
	
	return item

func is_empty():
	return !item_stack_gui

func clear() -> void:
	if item_stack_gui:
		container.remove_child(item_stack_gui)
		item_stack_gui = null
