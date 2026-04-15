extends Node
class_name CombatMath

# ----------------------------
# CORE FORCE CALCULATIONS
# ----------------------------

# Calculates outgoing attack force.
static func attack_force(base_impact: float, might: float, speed: float, momentum: float) -> float:
	return base_impact * (1.0 + might / 100.0) * (1.0 + speed / 150.0) * (1.0 + momentum / 200.0)

# Calculates resisting force for a defender.
static func resist_force(guard: float, endurance: float, timing_multiplier: float) -> float:
	return guard * (1.0 + endurance / 100.0) * timing_multiplier

# Calculates net force after defense is applied.
static func net_force(attack_force_value: float, resist_force_value: float) -> float:
	return attack_force_value - resist_force_value

# Calculates prototype knockback amount.
static func knockback_amount(net_force_value: float, knockback_resist: float) -> float:
	return max(0.0, net_force_value - knockback_resist) * 2.0


# ----------------------------
# SENSOR / RANGE CALCULATIONS
# ----------------------------

# How far this actor can sense danger.
static func perception_radius(insight: float, calm: float) -> float:
	return 80.0 + insight * 6.0 + calm * 2.0

# How far this actor can cover in about 1 second.
# This is your movement pressure circle.
static func one_second_speed_range(move_speed: float) -> float:
	return move_speed * 1.0

# How far this actor can actually threaten in combat.
# IMPORTANT:
# This should be the SAME number used for both:
# - drawing the attack ring
# - checking if an attack can land
static func effective_attack_range(move_speed: float, weapon_reach: float, attack_buffer: float = 20.0) -> float:
	return one_second_speed_range(move_speed) + weapon_reach + attack_buffer

# Whether a target is inside attack range.
static func target_in_attack_range(attacker_pos: Vector2, target_pos: Vector2, move_speed: float, weapon_reach: float, attack_buffer: float = 20.0) -> bool:
	var distance := attacker_pos.distance_to(target_pos)
	var range_value := effective_attack_range(move_speed, weapon_reach, attack_buffer)
	return distance <= range_value

# Returns how much warning time a player gets before danger matters.
# Bigger perception gives more warning.
static func reaction_window_ms(perception_radius_value: float, threat_distance: float, base_ms: float = 350.0) -> float:
	var distance_margin: float = float(max(0.0, perception_radius_value - threat_distance))
	return base_ms + distance_margin * 6.0

# Whether another actor is inside your perception ring.
static func target_in_perception_range(observer_pos: Vector2, target_pos: Vector2, insight: float, calm: float) -> bool:
	var distance := observer_pos.distance_to(target_pos)
	var radius := perception_radius(insight, calm)
	return distance <= radius