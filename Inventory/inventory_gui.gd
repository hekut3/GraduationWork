extends Control

signal opened
signal closed

var is_open_inventory: bool = false

func open():
	visible = true
	is_open_inventory = true
	opened.emit()

func close():
	visible = false
	is_open_inventory = false
	closed.emit()
