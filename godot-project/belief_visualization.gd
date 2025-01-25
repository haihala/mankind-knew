extends ColorRect

var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.PURPLE, Color.TEAL]
var last_drawn = 0

@onready var stats = get_tree().get_first_node_in_group("stats")
@onready var spawner = get_tree().get_first_node_in_group("spawner")

func _ready() -> void:
	assert(colors.size() == NPC.Belief.values().size())

func _draw() -> void:
	var bar_width = size.x/stats.state_log.size()
	var height_scaler = size.y / spawner.amount
	for time in range(stats.state_log.size()):
		var state = stats.state_log[time]
		var bottom = size.y
		for belief in NPC.Belief.values():
			var height = height_scaler * state[belief]
			var rect = Rect2(
				time * bar_width,
				bottom-height,
				bar_width,
				height
			)
			draw_rect(rect, colors[belief])
			bottom -= height

func _process(_delta: float) -> void:
	if last_drawn != stats.state_log.size():
		last_drawn = stats.state_log.size()
		queue_redraw()
