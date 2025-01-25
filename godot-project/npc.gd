extends CharacterBody2D
class_name NPC

enum Belief {RED, GREEN, BLUE, PURPLE, TEAL}

@export var projectile_scene: PackedScene
@export var speed: float = 50
var next_direction: Vector2
var prev_direction: Vector2
var beliefs: Dictionary = {}
var total_belief: float = 0

func _ready():
	add_belief(Belief.values().pick_random(), 0.2)
	update_decisions()

func _physics_process(delta: float) -> void:
	act_on_decisions()

func update_decisions():
	prev_direction = next_direction
	next_direction = Vector2.from_angle(randf()*PI*2)

func shoot():
	var projectile = projectile_scene.instantiate()
	projectile.rotation = randf()*PI*2
	projectile.creator = self
	projectile.position = position

	# Get a random belief
	var rand_belief = randf() * total_belief
	for belief in beliefs:
		var amount = beliefs[belief]
		if rand_belief < amount:
			projectile.belief = belief
			break
		rand_belief -= amount

	get_parent().add_child(projectile)

func act_on_decisions():
	var phase = $DecisionTimer.time_left / $DecisionTimer.wait_time
	var direction = phase * prev_direction + (1-phase) * next_direction
	velocity = direction * speed
	move_and_slide()

func add_belief(belief: Belief, amount: float):
	var current = beliefs.get_or_add(belief, 0)
	beliefs[belief] = current + amount
	
	var total = 0
	for key in beliefs:
		total += beliefs[key]
	
	# Evenly shrink every belief so that we get under the total
	if total > 1:
		for key in beliefs:
			beliefs[key] /= total
		total_belief = 1
	else:
		total_belief = total

	$ShotTimer.wait_time = 0.5 / total_belief

func influence(belief: Belief):
	add_belief(belief, 0.2)
	print_debug(beliefs)
