extends Node2D

var data = {}
var task_count = 0

var preloaded_taskpanel = preload("res://task_panel.tscn")
var preloaded_tolumber = preload("res://tolumber.tscn")


func _ready():
	load_data()
	update_taskpanels()


func _on_texture_button_pressed():
	if %TaskInput.text == "":
		print("not saving empty task")
		return
		
	add_task_to_data(%TaskInput.text)
	update_taskpanels()
	%TaskInput.text = ""
	update_taskpanels()
	save()
	
	var new_todookie = preloaded_tolumber.instantiate()
	add_child(new_todookie)
	new_todookie.global_position = Vector2(325, 943)
	

func load_data():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	if save_game == null:
		print("no savegame file found")
		return null

	var json_string = save_game.get_line()
	# Creates the helper class to interact with JSON
	var json = JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return null
	# Get the data from the JSON object
	self.data = json.get_data()
	
	# Get task_counter value
	json_string = save_game.get_line()
	parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return null
	self.task_count = json.get_data()
		
		
func save():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	print("saving: ", data)
	var data_json_string = JSON.stringify(data)
	var task_count_json_string = JSON.stringify(task_count)

	save_game.store_line(data_json_string)
	save_game.store_line(task_count_json_string)
	
	
func add_task_to_data(text):
	data[task_count] = text
	task_count += 1


func update_taskpanels():
	for taskpanel in %TaskPanelVbox.get_children():
		taskpanel.queue_free()
		
	for task in data:
		var new_panel = preloaded_taskpanel.instantiate()
		%TaskPanelVbox.add_child(new_panel)
		new_panel.task_finished_signal.connect(_on_task_finished)
		new_panel.task_id = task
		new_panel.task_string = data[task]
		new_panel.set_tasklabel_text(data[task])


func delete_task_from_data(target_id):
	data.erase(target_id)
	save()
	

func _on_task_finished(task_panel):
#	create_todookie()
	delete_task_from_data(task_panel.task_id)
	task_panel.queue_free()
