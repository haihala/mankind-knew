extends CharacterBody2D

@export var speed: float = 50
var next_direction: Vector2
var prev_direction: Vector2

func _physics_process(delta: float) -> void:
	act_on_decisions()

func update_decisions():
	prev_direction = next_direction
	next_direction = Vector2.from_angle(randf()*PI*2)

func shoot():
	print("shoot")

func act_on_decisions():
	var phase = $DecisionTimer.time_left / $DecisionTimer.wait_time
	var direction = phase * prev_direction + (1-phase) * next_direction
	velocity = direction * speed
	move_and_slide()

func influence():
	print("I'm being influenced")
