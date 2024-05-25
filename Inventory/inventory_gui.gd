extends Control

signal opened
signal closed

var is_open_inventory: bool = false

@onready var inventory: Inventory = preload("res://Inventory/playerInventory.tres")
@onready var item_stack_gui_class = preload("res://Gui/items_stack_gui.tscn")
@onready var hotbar_slots: Array = $NinePatchRect/HBoxContainer.get_children()
@onready var slots: Array = hotbar_slots + $NinePatchRect/GridContainer.get_children()

var item_in_hand: ItemStackGui

func _ready():
	connect_slot()
	inventory.updated.connect(update)
	update()

func connect_slot():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventory_slot: InventorySlot = inventory.slots[i]
		
		if !inventory_slot.item: continue
		
		var item_stack_gui: ItemStackGui = slots[i].item_stack_gui
		if !item_stack_gui:
			item_stack_gui = item_stack_gui_class.instantiate()
			slots[i].insert(item_stack_gui)
		
		item_stack_gui.inventory_slot = inventory_slot
		item_stack_gui.update()

func open():
	visible = true
	is_open_inventory = true
	opened.emit()

func close():
	visible = false
	is_open_inventory = false
	closed.emit()

func on_slot_clicked(slot):
	if slot.is_empty():
		if !item_in_hand: return
		
		insert_item_in_slot(slot)
		return
		
	if !item_in_hand:
		take_item_from_slot(slot)
		return
	
	swap_items(slot)
	
func take_item_from_slot(slot):
	item_in_hand = slot.take_item()
	add_child(item_in_hand)
	update_item_hand()

func insert_item_in_slot(slot):
	var item = item_in_hand
	
	remove_child(item_in_hand)
	item_in_hand = null
	
	slot.insert(item)

func swap_items(slot):
	var temp_item = slot.take_item()
	
	insert_item_in_slot(slot)
	
	item_in_hand = temp_item
	add_child(item_in_hand)
	update_item_hand()
	

func update_item_hand():
	if !item_in_hand: return
	item_in_hand.global_position = get_global_mouse_position() - item_in_hand.size / 2
	
func _input(_event):
	update_item_hand()
