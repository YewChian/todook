extends Panel

var task_id
var task_string

signal task_finished_signal(node)


func finish_task():
	task_finished_signal.emit(self)


func _on_done_button_pressed():
	print("pressed")
	finish_task()
	

func set_tasklabel_text(text):
	%TaskLabel.text = text
