extends CharacterBody2D

class_name Player

@export var projectile_scene: PackedScene
@export var speed: float = 150
@export var extract_distance: float = 100
@export var release_interval: float = 10
@export var max_hat_height: float = 50
@export var hat_fall_speed: float = 0.1
@export var hat_capacity: float = 3
@export var eyes_offset: float = 5
@export var eyes_speed: float = 0.1
@export_range(0, PI) var spread: float = PI/2

var beliefs: Dictionary = {}
var total_belief: float = 0
var last_direction: Vector2 = Vector2(1, 0)

var hat_offset: Vector2
var hat_height = 1
var shot_cost = Projectile.size / hat_capacity
var releasing = false

func _ready() -> void:
	hat_offset = $HatShaft.position
	$HatShaftFill.scale.y = max_hat_height
	$HatShaftFill.position = hat_offset - Vector2(0, max_hat_height/2 - 1.1)
	$Body.play("default")
	
	# Web shaders are broken, use colors
	if OS.has_feature("web"):
		$HatShaftFill.material.set_shader_parameter("use_colors", true)

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var cam = get_viewport().get_camera_2d()
		var mouse_pos = cam.get_global_mouse_position()
		direction = (mouse_pos - position).normalized()
	velocity = direction * speed / max(1, total_belief)

	if direction.is_zero_approx():
		$Body.pause()
	else:
		$Body.play("default")
		last_direction = direction

	z_index = int(position.y * 10)
	
	if releasing:
		hat_height = min(1, total_belief)
	else:
		hat_height = clamp(hat_height - delta * hat_fall_speed, total_belief, 1)
	
	if total_belief == hat_height:
		releasing = true

	move_and_slide()

func _process(_delta: float) -> void:
	visualize_hat()
	move_eyes()

func visualize_hat() -> void:
	var hh = max_hat_height*hat_height
	$HatShaft.position = hat_offset - Vector2(0, hh/2)
	$HatShaft.scale.y = hh
	$Hat.position = hat_offset - Vector2(0, hh)
	$HatShaftFill.material.set_shader_parameter("hat_height", max(1, total_belief) * max_hat_height / 12)

	var vis_beliefs = []
	for belief in NPC.Belief.values():
		vis_beliefs.push_back(beliefs.get(belief, 0) / max(total_belief, 1))
	$HatShaftFill.material.set_shader_parameter("beliefs", vis_beliefs)

func move_eyes() -> void:
	var target_pos = last_direction * eyes_offset
	$Eyes.position = target_pos * eyes_speed + $Eyes.position * (1 - eyes_speed)


func release() -> void:
	if not releasing:
		return
		
	if beliefs.is_empty():
		hat_height = 1
		releasing = false
	else:
		shoot()

func shoot() -> void:
	var projectile = projectile_scene.instantiate()
	projectile.rotation = randf()*spread - spread/2 + last_direction.angle()
	projectile.creator = self

	# Get a random belief
	var rand_belief = randf() * total_belief
	for belief in beliefs:
		var amount = beliefs[belief]
		if rand_belief < amount:
			projectile.belief = belief
			
			if amount <= shot_cost:
				total_belief -= beliefs[belief]
				beliefs.erase(belief)
			else:
				total_belief -= shot_cost
				beliefs[belief] -= shot_cost
			get_parent().add_child(projectile)
			break
		rand_belief -= amount


func influence(belief: NPC.Belief, amount: float = 0.2/hat_capacity) -> void:
	beliefs[belief] = beliefs.get(belief, 0) + amount
	total_belief += amount
