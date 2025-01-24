extends Area2D

@export var speed: float = 50
var creator: Node

func _physics_process(delta: float) -> void:
	var velocity = Vector2.from_angle(rotation) * speed
	position += velocity * delta

func collision(body: Node2D):
	if body == creator:
		return

	if body.has_method("influence"):
		body.influence()
	queue_free()
