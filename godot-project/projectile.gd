extends Area2D

class_name Projectile
static var size = 0.2

@export var speed: float = 50
@export var sprites: Array[Texture2D] = []
@export var npc_sounds: Array[AudioStream] = []
@export var player_sounds: Array[AudioStream] = []
@export_range(0, 4) var on_hit_grow: float = 1
@export var sparkle_scene: PackedScene
var belief: NPC.Belief
var creator: Node
var touched: Array[Node] = []
var extra_velocity = Vector2.ZERO

func _ready() -> void:
	$Sprite.texture = sprites[belief]
	$Sprite.rotation = -rotation
	position = creator.position

	if creator is Player:
		extra_velocity = creator.velocity
		speed *= 2

	var stats = get_tree().get_first_node_in_group("stats")
	if not stats.done:
		if creator is Player:
			$SpawnSound.volume_db += 10
			$SpawnSound.stream = player_sounds.pick_random()
		else:
			$SpawnSound.stream = npc_sounds.pick_random()
		$SpawnSound.play()

func _physics_process(delta: float) -> void:
	var velocity = Vector2.from_angle(rotation) * speed + extra_velocity
	var alpha = $DespawnTimer.time_left / $DespawnTimer.wait_time
	$Sprite.modulate.a = alpha
	position += velocity * delta
	
	# Scale self on hit
	var scale_phase = $SizeAdjustmentTimer.time_left / $SizeAdjustmentTimer.wait_time
	var easing = 1-pow(2*scale_phase-1, 2)
	var scaler = 1 + easing * on_hit_grow
	scale = Vector2(scaler, scaler)

func collision(body: Node2D) -> void:
	if body == creator or body in touched:
		return

	if body.has_method("influence"):
		body.influence(belief)
		touched.push_back(body)
		
		var sparkle = sparkle_scene.instantiate()
		sparkle.position = position
		sparkle.material.set_shader_parameter("color", NPC.new().border_colors[belief])
		get_parent().add_child(sparkle)
		
		$SizeAdjustmentTimer.start()
		# Restart despawn timer
		# This increases the time exponentially, growing for each encounter
		$DespawnTimer.start(1.1*$DespawnTimer.wait_time)
