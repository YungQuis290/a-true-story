extends Node
class_name CombatMath

static func attack_force(base_impact: float, might: float, speed: float, momentum: float) -> float:
	return base_impact * (1.0 + might / 100.0) * (1.0 + speed / 150.0) * (1.0 + momentum / 200.0)

static func resist_force(guard: float, endurance: float, timing_multiplier: float) -> float:
	return guard * (1.0 + endurance / 100.0) * timing_multiplier

static func net_force(attack_force_value: float, resist_force_value: float) -> float:
	return attack_force_value - resist_force_value

static func knockback_amount(net_force_value: float, knockback_resist: float) -> float:
	return max(0.0, net_force_value - knockback_resist) * 2.0

static func perception_radius(insight: float, calm: float) -> float:
	return 80.0 + insight * 6.0 + calm * 2.0

static func speed_reach_radius(move_speed: float, weapon_reach: float, dash_buffer: float) -> float:
	return move_speed + weapon_reach + dash_buffer