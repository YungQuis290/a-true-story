extends Node

func _ready() -> void:
	print("=== LOADING CHARACTERS ===")
	
	# Load player JSON
	var player = CharacterLoader.load_character("res://data/characters/player_test.json")
	
	# Load NPC JSON
	var npc = CharacterLoader.load_character("res://data/characters/npc_test.json")
	
	# Print raw data to confirm loading works
	print("Player Data: ", player)
	print("NPC Data: ", npc)
	
	# ---- Extract stats for testing ----
	var player_might = player["core_attributes"]["might"]
	var player_speed = player["core_attributes"]["dexterity"]
	var player_momentum = player["combat_state"]["momentum"]
	var player_base_impact = player["weapon"]["base_impact"]
	
	var npc_guard = npc["core_attributes"]["endurance"]
	var npc_resist = npc["core_attributes"]["endurance"]
	
	# ---- Run combat math ----
	var atk = CombatMath.attack_force(player_base_impact, player_might, player_speed, player_momentum)
	
	var res = CombatMath.resist_force(npc_guard, npc_resist, 1.2)
	
	var net = CombatMath.net_force(atk, res)
	
	var kb = CombatMath.knockback_amount(net, 5)
	
	# ---- Print results ----
	print("=== COMBAT TEST ===")
	print("Attack Force: ", atk)
	print("Resist Force: ", res)
	print("Net Force: ", net)
	print("Knockback: ", kb)