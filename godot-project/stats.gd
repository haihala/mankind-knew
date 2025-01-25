extends Node

var log: Array[Dictionary] = []

func record_state() -> void:
	var state = {}
	for npc in get_tree().get_nodes_in_group("npc"):
		for belief in NPC.Belief.values():
			state[belief] = state.get(belief, 0) + npc.beliefs.get(belief, 0)
	log.push_back(state)
