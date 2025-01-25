extends Area2D

class_name Projectile
static var size = 0.2

@export var speed: float = 50
var belief: NPC.Belief
var creator: Node

func _physics_process(delta: float) -> void:
	var velocity = Vector2.from_angle(rotation) * speed
	position += velocity * delta

func collision(body: Node2D) -> void:
	if body == creator:
		return

	if body.has_method("influence"):
		body.influence(belief)
	queue_free()
