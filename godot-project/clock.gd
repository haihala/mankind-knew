extends Label

@onready var stats = get_tree().get_first_node_in_group("stats")
@onready var start_time = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if stats.done:
		return
	
	var elapsed = Time.get_ticks_msec() - start_time
	var mins = int(elapsed / (60*1000.0))
	var secs = int(elapsed / 1000.0) % 60
	text = "%02d:%02d" % [mins, secs]
