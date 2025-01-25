extends Node2D

@export var amount = 20
@export var npc_scene: PackedScene

func _ready() -> void:
	var size = $Area2D/CollisionShape2D.shape.get_rect().size * scale
	var min_x = position.x - size.x/2
	var max_x = position.x + size.x/2
	var min_y = position.y - size.y/2
	var max_y = position.y + size.y/2
	
	for i in range(amount):
		var npc = npc_scene.instantiate()
		npc.position.x = randf_range(min_x, max_x)
		npc.position.y = randf_range(min_y, max_y)
		get_parent().add_child.call_deferred(npc)
