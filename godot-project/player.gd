extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var speed: float = 150
@export var extract_distance: float = 100
@export var release_interval: float = 10
@export var max_hat_height: float = 50
@export var hat_fall_speed: float = 0.1
@export var eyes_offset: float = 5
@export var eyes_speed: float = 0.1
@export_range(0, PI) var spread: float = PI/2

var beliefs: Dictionary = {}
var total_belief: float = 0
var last_direction: Vector2 = Vector2(1, 0)

var hat_offset: Vector2
var hat_height = 1

func _ready() -> void:
	hat_offset = $HatShaft.position
	$HatShaftFill.scale.y = max_hat_height
	$HatShaftFill.position = hat_offset - Vector2(0, max_hat_height/2)
	$HatShaftFill.material.set_shader_parameter("colors", NPC.new().colors)
	$Body.play("default")

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = direction * speed / max(1, total_belief)

	if direction.is_zero_approx():
		$Body.pause()
	else:
		$Body.play("default")
		last_direction = direction

	z_index = int(position.y * 10)
	
	hat_height -= delta * hat_fall_speed
	if total_belief > hat_height:
		release()

	visualize_hat()
	move_eyes()
	move_and_slide()

func visualize_hat() -> void:
	$HatShaft.position = hat_offset - Vector2(0, max_hat_height*hat_height/2)
	$HatShaft.scale.y = max_hat_height*hat_height
	$Hat.position = hat_offset - Vector2(0, max_hat_height*hat_height)

	var vis_beliefs = []
	for belief in NPC.Belief.values():
		vis_beliefs.push_back(beliefs.get(belief, 0) / max(total_belief, 1))
	$HatShaftFill.material.set_shader_parameter("beliefs", vis_beliefs)

func move_eyes() -> void:
	var target_pos = last_direction * eyes_offset
	$Eyes.position = target_pos * eyes_speed + $Eyes.position * (1 - eyes_speed)


func release() -> void:
	while not beliefs.is_empty():
		var projectile = projectile_scene.instantiate()
		projectile.rotation = randf()*spread - spread/2 + last_direction.angle()
		projectile.creator = self
		projectile.position = position

		# Get a random belief
		var rand_belief = randf() * total_belief
		for belief in beliefs:
			var amount = beliefs[belief]
			if rand_belief < amount:
				projectile.belief = belief
				
				if amount <= Projectile.size:
					total_belief -= beliefs[belief]
					beliefs.erase(belief)
				else:
					beliefs[belief] -= Projectile.size
					total_belief -= Projectile.size
				break
			rand_belief -= amount

		get_parent().add_child(projectile)
	hat_height = 1
func influence(belief: NPC.Belief, amount: float = 0.2) -> void:
	beliefs[belief] = beliefs.get(belief, 0) + amount
	total_belief += amount
