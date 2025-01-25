extends CharacterBody2D
class_name NPC

enum Belief {RED, GREEN, BLUE, PURPLE, TEAL}
static var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.PURPLE, Color.TEAL]

@export var projectile_scene: PackedScene
@export var speed: float = 50
@export var max_direction_influence_per_npc: float = 0.2
var next_direction: Vector2
var prev_direction: Vector2
var beliefs: Dictionary = {}
var total_belief: float = 0

func _ready() -> void:
	assert(colors.size() == Belief.values().size())

	for belief in Belief.values():
		beliefs[belief] = 0
	add_belief(Belief.values().pick_random(), Projectile.size)
	update_decisions()

func _physics_process(_delta: float) -> void:
	act_on_decisions()

func update_decisions() -> void:
	prev_direction = next_direction
	var random_direction = Vector2.from_angle(randf()*PI*2)
	var middle_pull = (-position).normalized() * 0.1
	var npc_influence = Vector2.ZERO

	for npc in get_tree().get_nodes_in_group("npc"):
		if npc == self:
			continue
		
		var similarity = calculate_similarity(npc)
		var direction = (npc.position - position).normalized()
		npc_influence += max_direction_influence_per_npc * direction * similarity
	next_direction = (random_direction + middle_pull + npc_influence).normalized()

# From 0 to 1
func calculate_similarity(npc: NPC) -> float:
	var similarity = 0
	
	for belief in Belief.values():
		similarity += beliefs.get(belief, 0) * npc.beliefs.get(belief, 0)

	return similarity

func shoot(angle: float = randf()*PI*2) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.rotation = angle
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

func act_on_decisions() -> void:
	var phase = $DecisionTimer.time_left / $DecisionTimer.wait_time
	var direction = phase * prev_direction + (1-phase) * next_direction
	velocity = direction * speed
	move_and_slide()

func add_belief(belief: Belief, amount: float) -> void:
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

func influence(belief: Belief) -> void:
	add_belief(belief, Projectile.size)

func shoot_towards(target: Node2D) -> void:
	shoot(position.angle_to(target.position))
	
