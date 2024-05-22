extends Panel

class_name ItemStackGui

@onready var itemSprite: Sprite2D = $item
@onready var amountLabel: Label = $Label

var inventory_slot: InventorySlot

func update():
	if !inventory_slot || !inventory_slot.item: return
	
	itemSprite.visible = true
	itemSprite.texture = inventory_slot.item.texture
	if inventory_slot.amount > 1:
		amountLabel.visible = true
		amountLabel.text = str(inventory_slot.amount)
	else:
		amountLabel.visible = false
