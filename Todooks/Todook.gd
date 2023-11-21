extends CharacterBody2D
class_name Todook


var move_speed
var move_direction = Vector2(0,0)
var state
var lifespan

enum {
	Wander,
}


func _ready():
	initialize_stats()
	state = Wander
	$StateTimer.start(1)
	$LifeTimer.start(lifespan)
	
	
func initialize_stats():
	pass

func _physics_process(delta):
	match state:
		Wander:
			move_and_collide(move_direction * move_speed)


func choose_new_state(current_state):
	match current_state:
		Wander:
			var available_states = [Wander]
			available_states.shuffle()
			print("bad array: ", available_states)
			return available_states[0]


func enter_state(new_state):
	match new_state:
		Wander:
			randomize()
			var new_move_direction_x = randi()%3 - 1
			randomize()			
			var new_move_direction_y = randi()%3 - 1
			
			move_direction = Vector2(new_move_direction_x, new_move_direction_y).normalized()


func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,

	}
	return save_dict
	
	
func _on_state_timer_timeout():
	print("timed out")
	
	var new_state = choose_new_state(state)
	print(new_state)
	enter_state(new_state)
	$StateTimer.start(10)


func _on_life_timer_timeout():
	queue_free()
