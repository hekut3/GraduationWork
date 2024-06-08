extends Control

signal dialogue_finished

@export_file("*.json") var dialogue_file

var dialogue = []
var current_dialogue_id = 0
var dialogue_active = false
var character_name = ""

func _ready():
	$NinePatchRect.visible = false
	
func start(character, dialogue_number):
	if dialogue_active:
		return
	character_name = character
	dialogue_active = true
	$NinePatchRect.visible = true
	dialogue = load_dialogue(character_name, dialogue_number)
	current_dialogue_id = -1
	next_script()
	
func load_dialogue(character, dialogue_number):
	var file_path = "res://NPC/" + character + "_dialogues/" + character + "_dialogue" + str(dialogue_number) + ".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content
	
func _input(event):
	if !dialogue_active:
		return
	if event.is_action_pressed("ui_accept"):
		next_script()

func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		dialogue_active = false
		$NinePatchRect.visible = false
		emit_signal("dialogue_finished")
		return
	
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]["name"]
	$NinePatchRect/Text.text = dialogue[current_dialogue_id]["text"]
