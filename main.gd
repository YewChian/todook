extends Node2D

var data = {}
var task_count = 0

var preloaded_taskpanel = preload("res://task_panel.tscn")
var preloaded_reacher = preload("res://Todooks/Reacher.tscn")

var greatcrystal_node = null

func _ready():
	load_data()
	update_taskpanels()
	initialize_map()
	

func initialize_map():
	greatcrystal_node = create_greatcrystal()
	create_land1_boundary(greatcrystal_node.global_position)

func create_land1_boundary(map_center_position):
	var loaded_boulder_scene = load("res://Structures/Boulder.tscn")
	var land1_radius = 360
	var land1_circumference = 2 * PI * land1_radius
	var test_boulder = loaded_boulder_scene.instantiate()
	var boulder_width = test_boulder.get_node("Skeleton").shape.get_radius() * 2
	var boulder_padding = 8
	test_boulder.queue_free()
	var number_of_boulders = floor(land1_circumference / (boulder_width + boulder_padding))
	
	var new_boulder
	var angle_from_center = 0
	for i in number_of_boulders:
		new_boulder = loaded_boulder_scene.instantiate()
		$Structures.add_child(new_boulder)
		new_boulder.global_position = map_center_position + (Vector2.from_angle(angle_from_center) * land1_radius)
		
		angle_from_center += (2*PI/number_of_boulders)

	Globals.land_radius = land1_radius
	

func get_random_position_near_node(node_position, radius):
	randomize()
	var random_angle = (randi()%360)*(PI/180)
	randomize()
	var random_scale = float(((randi()%32)+48))/100
	print(random_scale)
	return node_position + (Vector2.from_angle(random_angle) * radius * random_scale)
	
	
func create_greatcrystal():
	var loaded_greatcrystal_scene = load("res://Structures/GreatCrystal.tscn")
	var new_greatcrystal = loaded_greatcrystal_scene.instantiate()
	$Structures.add_child(new_greatcrystal)
	new_greatcrystal.global_position = Vector2(360, 800)
	return new_greatcrystal


func _on_texture_button_pressed():
	if %TaskInput.text == "":
		print("not saving empty task")
		return
		
	add_task_to_data(%TaskInput.text)
	update_taskpanels()
	%TaskInput.text = ""
	update_taskpanels()
	
	create_todook()
	save()

func create_todook():
	var new_todook = preloaded_reacher.instantiate()
	add_child(new_todook)
	new_todook.global_position = get_random_position_near_node(greatcrystal_node.global_position, Globals.land_radius)
	

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
	
	# load node data here
	while save_game.get_position() < save_game.get_length():
		json_string = save_game.get_line()
		json = JSON.new()

		parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data = json.get_data()

		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.global_position = Vector2(node_data["pos_x"], node_data["pos_y"])

		
func save():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	print("saving: ", data)
	var data_json_string = JSON.stringify(data)
	var task_count_json_string = JSON.stringify(task_count)

	save_game.store_line(data_json_string)
	save_game.store_line(task_count_json_string)
	
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
			
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
			
		var node_data = node.call("save")
		var node_data_json_string = JSON.stringify(node_data)
		save_game.store_line(node_data_json_string)

	
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
