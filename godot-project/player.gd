extends CharacterBody2D

@export var speed: float = 150

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = speed * direction

	move_and_slide()
