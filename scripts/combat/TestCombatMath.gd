extends Node

func _ready() -> void:
	var atk := CombatMath.attack_force(20, 10, 14, 0)
	var res := CombatMath.resist_force(12, 12, 1.5)
	var net := CombatMath.net_force(atk, res)
	var kb := CombatMath.knockback_amount(net, 5)

	print("Attack Force: ", atk)
	print("Resist Force: ", res)
	print("Net Force: ", net)
	print("Knockback: ", kb)