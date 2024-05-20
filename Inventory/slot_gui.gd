extends Panel

@onready var itemSprite: Sprite2D = $CenterContainer/Panel/item
@onready var amountLabel: Label = $CenterContainer/Panel/Label

func update(slot: InventorySlot):
	if !slot.item:
		itemSprite.visible = false
		amountLabel.visible = false
	else:
		itemSprite.visible = true
		itemSprite.texture = slot.item.texture
		amountLabel.visible = true
		amountLabel.text = str(slot.amount)
