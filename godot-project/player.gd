extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var speed: float = 150
@export var extract_distance: float = 100
@export var release_interval: float = 10

var beliefs: Dictionary = {}
var total_belief: float = 0 


func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = direction * speed / max(1, total_belief)

	if Input.is_action_just_pressed("interact") and $ExtractTimer.is_stopped():
		extract()

	$CanvasLayer/ColorRect.scale.x = 1-($ReleaseTimer.time_left / release_interval)

	z_index = position.y * 10
	move_and_slide()

func extract() -> void:
	for npc in get_tree().get_nodes_in_group("npc"):
		if (position - npc.position).length() < extract_distance:
			npc.shoot_towards(self)

	if Input.is_action_pressed("interact"):
		$ExtractTimer.start()

func release() -> void:
	while not beliefs.is_empty():
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
	$ReleaseTimer.start(release_interval)

func influence(belief: NPC.Belief, amount: float = 0.2) -> void:
	beliefs[belief] = beliefs.get(belief, 0) + amount
	total_belief += amount
	$ReleaseTimer.start($ReleaseTimer.time_left - 0.1)
