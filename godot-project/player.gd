extends CharacterBody2D

enum State {EMPTY, CARRYING, EXTRACTING, RELEASING}

@export var projectile_scene: PackedScene
@export var speed: float = 150
@export var extract_distance: float = 200

var beliefs: Dictionary = {}
var total_belief: float = 0
var state: State = State.EMPTY

var NPCs: Array[Node]

func _physics_process(_delta: float) -> void:
	if NPCs.is_empty():
		NPCs = get_parent().get_tree().get_nodes_in_group("npc")

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = direction * speed / max(1, total_belief)

	handle_state_changes()

	move_and_slide()

func handle_state_changes() -> void:
	# Essentially you cycle:
	# - Start in empty
	# - Press to extract
	# - Release to carry (or empty if you don't have beliefs)
	# - Press to release
	# - Release to go back to empty (or carrying if has content)
	if Input.is_action_just_pressed("interact"):
		if state == State.EMPTY:
			state = State.EXTRACTING
			$ExtractTimer.start(0.4)
		elif state == State.CARRYING:
			state = State.RELEASING
			$ReleaseTimer.start(0.1)

	if Input.is_action_just_released("interact"):
		if state == State.EXTRACTING or state == State.RELEASING:
			if beliefs.is_empty():
				state = State.EMPTY
			else:
				state = State.CARRYING


func extract() -> void:
	if state != State.EXTRACTING:
		return

	# Pick a nearby NPC from cached NPC list
	var nearby = []
	for npc in NPCs:
		if (position - npc.position).length() < extract_distance:
			nearby.push_back(npc)

	# Extract belief from them
	if not nearby.is_empty():
		nearby.pick_random().shoot_towards(self)

func release() -> void:
	if state != State.RELEASING:
		return

	if beliefs.is_empty():
		state = State.EMPTY
		return

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
			total_belief -= amount
			
			if amount <= Projectile.size:
				beliefs.erase(belief)
			else:
				beliefs[belief] -= Projectile.size
			break
		rand_belief -= amount

	get_parent().add_child(projectile)

func influence(belief: NPC.Belief, amount: float = 0.2) -> void:
	var current = beliefs.get_or_add(belief, 0)
	beliefs[belief] = current + amount
	total_belief += amount
