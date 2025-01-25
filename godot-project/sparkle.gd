extends Sprite2D

func _ready() -> void:
	material = material.duplicate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var phase = 1 - ($DespawnTimer.time_left / $DespawnTimer.wait_time)
	material.set_shader_parameter("phase", phase)
