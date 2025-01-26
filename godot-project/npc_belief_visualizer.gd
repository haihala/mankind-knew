extends Node2D

@export_range(0, 1) var border_thickness: float
@export_range(0, 100) var offset: float
@export_range(0, 30) var max_size: float = 20
@export_range(0, 2*PI) var dead_angle: float
var target: Dictionary
var target_total: float
var prev_target: Dictionary
var prev_total: float

@onready var total_angle = (2*PI)-dead_angle

var children_setup = false

func _process(_delta: float) -> void:
	if get_parent().beliefs != target:
		retarget()

	if not children_setup:
		color_beliefs()
		children_setup = true

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
		child.scale = Vector2(val*max_size, val*max_size)
		
		angle += width

func color_beliefs() -> void:
	for belief in NPC.Belief.values():
		var child = get_child(belief)
		var core = child.get_node("./Core").material
		core.set_shader_parameter("color", Color.WHITE)
		core.set_shader_parameter("pattern", Colors.patterns[belief])
		core.set_shader_parameter("pattern_scale", Colors.pattern_scales[belief])
		core.set_shader_parameter("padding", border_thickness)
		var outline = child.get_node("./Outline").material
		outline.set_shader_parameter("color", Colors.border_colors[belief])
		outline.set_shader_parameter("padding", 0)
		
