extends Control

func _ready() -> void:
	hide()
	var stats = get_tree().get_first_node_in_group("stats")
	stats.connect("end_game", open)

func open() -> void:
	show()
	$AnimationPlayer.play("start_blur")

func replay() -> void:
	get_tree().reload_current_scene()
	
func quit() -> void:
	get_tree().quit()
