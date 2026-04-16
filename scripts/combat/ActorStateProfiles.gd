extends Node
class_name ActorStateProfiles

# ActorStateProfiles is the central table for combat posture/state multipliers.
#
# A posture/state is NOT a temporary status like bleeding or stunned duration.
# It is the actor's current tactical mode: passive, defensive, attack, speed,
# perceptive, hidden, or stunned.
#
# These multipliers should be used by CombatActor, SensorRings, AttackRay, AI,
# and reaction logic so that posture affects actual gameplay, not just visuals.
#
# Example:
# - Defensive increases perception and guard, but lowers attack pressure.
# - Attack increases force and threat range, but lowers incoming read quality.
# - Speed increases movement and ray speed, but weakens guard.

const DEFAULT_STATE_ID: String = "passive"

const PROFILES: Dictionary = {
	"passive": {
		"display_name": "Passive",
		"description": "Balanced neutral movement and awareness.",
		"perception_mult": 1.0,
		"attack_range_mult": 1.0,
		"move_mult": 1.0,
		"guard_mult": 1.0,
		"attack_force_mult": 1.0,
		"attack_speed_mult": 1.0,
		"reaction_mult": 1.0,
		"incoming_read_mult": 1.0,
		"outgoing_visibility_mult": 1.0,
		"stamina_regen_mult": 1.0,
		"stamina_cost_mult": 1.0,
		"clash_mult": 1.0
	},
	"defensive": {
		"display_name": "Defensive",
		"description": "Reads threats better and guards stronger, but gives up pressure and speed.",
		"perception_mult": 1.20,
		"attack_range_mult": 0.85,
		"move_mult": 0.80,
		"guard_mult": 1.35,
		"attack_force_mult": 0.85,
		"attack_speed_mult": 0.90,
		"reaction_mult": 1.25,
		"incoming_read_mult": 1.20,
		"outgoing_visibility_mult": 1.05,
		"stamina_regen_mult": 0.90,
		"stamina_cost_mult": 0.90,
		"clash_mult": 1.10
	},
	"attack": {
		"display_name": "Attack",
		"description": "Projects stronger attack information, but reads incoming danger worse.",
		"perception_mult": 0.80,
		"attack_range_mult": 1.15,
		"move_mult": 1.00,
		"guard_mult": 0.75,
		"attack_force_mult": 1.20,
		"attack_speed_mult": 1.10,
		"reaction_mult": 0.80,
		"incoming_read_mult": 0.80,
		"outgoing_visibility_mult": 1.20,
		"stamina_regen_mult": 0.85,
		"stamina_cost_mult": 1.15,
		"clash_mult": 1.15
	},
	"speed": {
		"display_name": "Speed",
		"description": "Moves and launches faster, but blocks and reads less reliably.",
		"perception_mult": 0.90,
		"attack_range_mult": 1.25,
		"move_mult": 1.30,
		"guard_mult": 0.80,
		"attack_force_mult": 0.90,
		"attack_speed_mult": 1.30,
		"reaction_mult": 1.05,
		"incoming_read_mult": 0.90,
		"outgoing_visibility_mult": 1.10,
		"stamina_regen_mult": 0.80,
		"stamina_cost_mult": 1.25,
		"clash_mult": 0.95
	},
	"perceptive": {
		"display_name": "Perceptive",
		"description": "Maximizes danger reading and reaction lead time, but reduces burst pressure.",
		"perception_mult": 1.45,
		"attack_range_mult": 0.90,
		"move_mult": 0.90,
		"guard_mult": 1.05,
		"attack_force_mult": 0.85,
		"attack_speed_mult": 0.90,
		"reaction_mult": 1.40,
		"incoming_read_mult": 1.45,
		"outgoing_visibility_mult": 0.95,
		"stamina_regen_mult": 1.00,
		"stamina_cost_mult": 1.00,
		"clash_mult": 1.00
	},
	"hidden": {
		"display_name": "Hidden",
		"description": "Harder to read and better for ambushes, but poor if caught directly.",
		"perception_mult": 0.95,
		"attack_range_mult": 0.95,
		"move_mult": 0.85,
		"guard_mult": 0.70,
		"attack_force_mult": 1.05,
		"attack_speed_mult": 0.95,
		"reaction_mult": 0.85,
		"incoming_read_mult": 0.85,
		"outgoing_visibility_mult": 0.55,
		"stamina_regen_mult": 1.10,
		"stamina_cost_mult": 0.95,
		"clash_mult": 0.80
	},
	"stunned": {
		"display_name": "Stunned",
		"description": "Cannot meaningfully react; perception and movement collapse.",
		"perception_mult": 0.35,
		"attack_range_mult": 0.20,
		"move_mult": 0.10,
		"guard_mult": 0.25,
		"attack_force_mult": 0.20,
		"attack_speed_mult": 0.20,
		"reaction_mult": 0.0,
		"incoming_read_mult": 0.25,
		"outgoing_visibility_mult": 1.30,
		"stamina_regen_mult": 0.50,
		"stamina_cost_mult": 1.50,
		"clash_mult": 0.0
	}
}

static func get_profile(state_id: String) -> Dictionary:
	# Return the requested profile.
	# Unknown state IDs fall back to passive so combat never crashes from bad data.
	if PROFILES.has(state_id):
		return PROFILES[state_id]
	return PROFILES[DEFAULT_STATE_ID]

static func get_value(state_id: String, key: String, fallback: float = 1.0) -> float:
	# Read a single multiplier from a state profile.
	# Example: ActorStateProfiles.get_value("defensive", "guard_mult")
	var profile: Dictionary = get_profile(state_id)
	return float(profile.get(key, fallback))

static func is_valid_state(state_id: String) -> bool:
	# Useful for validating JSON character data or editor-entered state strings.
	return PROFILES.has(state_id)
