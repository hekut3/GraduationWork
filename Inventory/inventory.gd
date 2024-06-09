extends Resource

class_name Inventory

signal updated
signal use

@export var slots: Array[InventorySlot]

func insert(item: InventoryItem):
	for slot in slots:
		if slot.item == item:
			slot.amount += 1
			updated.emit()
			return
	
	for i in range(slots.size()):
		if !slots[i].item:
			slots[i].item = item
			slots[i].amount = 1
			updated.emit()
			return

func remove_slot(inventory_slot: InventorySlot):
	var index = slots.find(inventory_slot)
	if index < 0: return
	
	remove_at_index(index)

func remove_at_index(index: int) -> void:
	slots[index] = InventorySlot.new()
	updated.emit()

func insert_slot(index: int, inventory_slot: InventorySlot):
	slots[index] = inventory_slot
	updated.emit()

func use_item(index: int) -> void:
	if index < 0 || index >= slots.size() || !slots[index].item: return
	
	var slot = slots[index]
	use.emit(slot.item)

	if slot.amount > 1:
		slot.amount -= 1
		updated.emit()
		return
	
	remove_at_index(index)
