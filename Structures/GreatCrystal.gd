extends Structure

var scatter_radius = 128
var preloaded_small_crystal = preload("res://Items/SmallCrystal.tscn")
var is_day = true


func initialize_structure():
	$DayNightTimer.start()
	is_day = true
	scatter_small_crystals()
	$CPUParticles2D.set_emitting(true)
	
	
func scatter_small_crystals():
	randomize()
	var number_of_crystals_scattered = randi_range(2, 4)
	for scatter_step in number_of_crystals_scattered:
		var new_small_crystal = preloaded_small_crystal.instantiate()
		randomize()
		get_tree().current_scene.get_node("Items").add_child(new_small_crystal)
		new_small_crystal.global_position = global_position + Vector2(randi_range(-scatter_radius, scatter_radius), randi_range(-scatter_radius, scatter_radius))



func _on_day_night_timer_timeout():
	if is_day == true:
		is_day = false
		$CPUParticles2D.set_emitting(false)
		
	elif is_day == false:
		is_day = true
		scatter_small_crystals()
		$CPUParticles2D.set_emitting(true)
