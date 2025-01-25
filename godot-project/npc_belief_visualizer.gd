extends Node2D

@export_range(0, 100) var offset: float
@export_range(0, 30) var max_size: float = 20
@export_range(0, 2*PI) var dead_angle: float
var target: Dictionary
var target_total: float
var prev_target: Dictionary
var prev_total: float

@onready var total_angle = (2*PI)-dead_angle

func _process(_delta: float) -> void:
	if get_parent().beliefs != target:
		retarget()

	update_visual()

func retarget() -> void:
	prev_target = target.duplicate()
	target = get_parent().beliefs.duplicate()
	
	prev_total = target_total
	target_total = get_parent().total_belief

	$SmoothTimer.start()

func update_visual() -> void:
	# 0-1, 0 when near the end
	var t = $SmoothTimer.time_left / $SmoothTimer.wait_time
	var angle = 0
	var total = prev_total * t + target_total * (1-t)
	for belief in NPC.Belief.values():
		var target_val = target.get(belief, 0)
		var prev_val = prev_target.get(belief, 0)
		# Lerp
		var val = prev_val * t + target_val * (1-t)
		var width = (val / total) * total_angle
		
		var child = get_child(belief)
		child.position = Vector2.from_angle(angle + width / 2) * offset
		child.material.set_shader_parameter("color", NPC.colors[belief])
		child.scale = Vector2(val*max_size, val*max_size)
		angle += width
