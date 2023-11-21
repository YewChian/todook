extends StaticBody2D
class_name Structure

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,

	}
	return save_dict


func _ready():
	call_deferred("initialize_structure")


func initialize_structure():
	pass

