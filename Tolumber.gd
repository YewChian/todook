extends CharacterBody2D

var move_speed = 0.2
var move_direction = Vector2(0,0)
var state
enum {
	Wander,
}


func _ready():
	state = Wander
	$StateTimer.start(1)
	


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
			
			print(move_direction)
			move_direction = Vector2(new_move_direction_x, new_move_direction_y).normalized()

func _on_state_timer_timeout():
	print("timed out")
	
	var new_state = choose_new_state(state)
	print(new_state)
	enter_state(new_state)
	$StateTimer.start(10)
