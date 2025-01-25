extends Area2D

class_name Projectile
static var size = 0.2

@export var speed: float = 50
@export var sprites: Array[Texture2D] = []
@export var sounds: Array[AudioStream] = []
var belief: NPC.Belief
var creator: Node
var touched: Array[Node] = []

# Ammu ajatuskuplan kasvu yli
# Sparkle kun osuu
# Pelaaja ehkä interact pois?
# Pelaaja ehkä 


func _ready() -> void:
	$Sprite.texture = sprites[belief]
	$Sprite.rotation = -rotation
	
	var stats = get_tree().get_first_node_in_group("stats")
	if not stats.done:
		$SpawnSound.stream = sounds.pick_random()
		$SpawnSound.play()

func _physics_process(delta: float) -> void:
	var velocity = Vector2.from_angle(rotation) * speed
	var alpha = ($DespawnTimer.time_left / $DespawnTimer.wait_time)
	$Sprite.modulate.a = alpha
	position += velocity * delta

func collision(body: Node2D) -> void:
	if body == creator or body in touched:
		return

	if body.has_method("influence"):
		body.influence(belief)
		touched.push_back(body)
