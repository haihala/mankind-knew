extends CharacterBody2D
class_name NPC

enum Belief {RED, GREEN, BLUE, PURPLE, ORANGE}
@export var colors: Array[Color] = [Color('FF3535'), Color('00D347'), Color('00AAFF'), Color('B01DDA'), Color('FFC900')]
@export var border_colors: Array[Color] = [Color('B40000'), Color('1A9874'), Color('005BD7'), Color('6D029C'), Color('E56F00')]
@export var projectile_scene: PackedScene
@export var speed: float = 30
@export var eyes_offset: float = 7

@export_category("Behavior weights")
@export var npc_influence_distance_falloff: Curve
@export var fellow_npc_pull = 0.1
@export var similarity_multiplier = 1
@export var repulsion_multiplier = 1
@export var center_pull = 0.2
@export var randomness = 2
@export_range(0, 1) var strong_belief_threshold = 0.6

var leftover = 2 - 2*strong_belief_threshold
var next_direction: Vector2
var prev_direction: Vector2
var beliefs: Dictionary = {}
var total_belief: float = 0
var strongest_belief: Belief
var initial_belief: Belief

func _ready() -> void:
	assert(colors.size() == Belief.values().size())
	$Body.play("default")

	for belief in Belief.values():
		beliefs[belief] = 0
	add_belief(initial_belief, Projectile.size)
	update_decisions()

func _physics_process(_delta: float) -> void:
	act_on_decisions()
	z_index = int(position.y * 10)

func update_decisions() -> void:
	prev_direction = next_direction
	var random_direction = Vector2.from_angle(randf()*PI*2) * randomness
	var middle_pull = (-position).normalized() * center_pull
	var npc_influence = Vector2.ZERO

	for npc in get_tree().get_nodes_in_group("npc"):
		if npc == self:
			continue
		
		var diff = npc.position - position
		var direction = diff.normalized()
		var distance_multiplier = npc_influence_distance_falloff.sample(diff.length() / 1000)
		
		var similarity = calculate_similarity(npc)
		var repulsion = calculate_polarization_repulsion(npc)
		var pull = fellow_npc_pull + similarity - repulsion
		npc_influence += distance_multiplier * direction * pull
	next_direction = (random_direction + middle_pull + npc_influence).normalized()

# From 0 to 1
func calculate_similarity(npc: NPC) -> float:
	var similarity = 0
	
	for belief in Belief.values():
		similarity += beliefs.get(belief, 0) * npc.beliefs.get(belief, 0)

	return similarity_multiplier * similarity

# From 0 to 1
func calculate_polarization_repulsion(npc: NPC) -> float:
	# Same strongest beliefs -> no repulsion
	if npc.strongest_belief == strongest_belief:
		return 0

	var strongest = beliefs[strongest_belief]
	var npc_strongest = npc.beliefs[npc.strongest_belief]
	var total_strength = strongest + npc_strongest
	return repulsion_multiplier * max((total_strength - 2*strong_belief_threshold) / leftover, 0)

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
	$Eyes.position = direction.normalized() * eyes_offset
	move_and_slide()

func add_belief(belief: Belief, amount: float) -> void:
	var current = beliefs.get_or_add(belief, 0)
	beliefs[belief] = current + amount
	
	var total = 0
	var strongest_belief_amount = 0
	for key in beliefs:
		var value = beliefs[key]
		total += value
		if value > strongest_belief_amount:
			strongest_belief = key
			strongest_belief_amount = value
	
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
	shoot((target.position - position).angle())
	
