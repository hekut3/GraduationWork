extends HBoxContainer

@onready var hearts_gui_class = preload("res://Gui/heart_gui.tscn")

func set_max_hearts(max_hearts: int):
	for i in range(max_hearts):
		var heart = hearts_gui_class.instantiate()
		add_child(heart)

func update_hearts(current_health: int):
	var hearts = get_children()
	
	for i in range(current_health):
		hearts[i].update(true)
		
	for i in range(current_health, hearts.size()):
		hearts[i].update(false)
