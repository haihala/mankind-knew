extends ColorRect


@onready var stats = get_tree().get_first_node_in_group("stats")
@onready var spawner = get_tree().get_first_node_in_group("spawner")


func _draw() -> void:
	var bar_width = size.x / (stats.state_log.size()-1)
	var height_scaler = size.y / spawner.amount
	
	var tops = [[], [], [], [], []]
	var bottoms = [[], [], [], [], []]
	for time in range(stats.state_log.size()):
		var x = time * bar_width
		var bottom = size.y
		var state = stats.state_log[time]
		for belief in NPC.Belief.values():
			var height = height_scaler * state[belief]
			var top = bottom - height
			bottoms[belief].push_front([x, bottom])
			tops[belief].push_back([x, top])
			bottom = top

	for belief in NPC.Belief.values():
		var bot = bottoms[belief]
		var top = tops[belief]
		bot.append_array(top)
		
		var child = get_child(belief)
		child.polygon = float_array_to_Vector2Array(bot)
		var npc = NPC.new()
		child.texture = npc.patterns[belief]
		var tex_scale = npc.pattern_ui_scales[belief]
		child.texture_scale = Vector2(tex_scale, tex_scale)

func float_array_to_Vector2Array(coords : Array) -> PackedVector2Array:
	# Convert the array of floats into a PackedVector2Array.
	var array : PackedVector2Array = []
	for coord in coords:
		array.append(Vector2(coord[0], coord[1]))
	return array
