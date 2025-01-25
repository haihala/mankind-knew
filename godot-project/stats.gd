extends Node

signal end_game
var done = false

var state_log: Array[Dictionary] = []
@onready var spawner = get_tree().get_first_node_in_group("spawner")

func record_state() -> void:
	if done:
		return

	var state = {}
	for npc in get_tree().get_nodes_in_group("npc"):
		for belief in NPC.Belief.values():
			state[belief] = state.get(belief, 0) + npc.beliefs.get(belief, 0)
	state_log.push_back(state)

	for belief in NPC.Belief.values():
		# End game when a belief has 95% support
		if state[belief] >= spawner.amount * 0.95:
			end_game.emit()
			done = true
	
