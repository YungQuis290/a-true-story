extends Node
class_name ActorStateProfiles

const DEFAULT_STATE := "passive"

const STATES := {
	"passive": {
		"perception_mult": 1.0,
		"attack_range_mult": 1.0,
		"move_mult": 1.0,
		"guard_mult": 1.0,
		"attack_speed_mult": 1.0,
		"attack_force_mult": 1.0,
		"incoming_read_mult": 1.0,
		"outgoing_visibility_mult": 1.0
	},
	"defensive": {
		"perception_mult": 1.2,
		"attack_range_mult": 0.85,
		"move_mult": 0.8,
		"guard_mult": 1.35,
		"attack_speed_mult": 0.9,
		"attack_force_mult": 0.85,
		"incoming_read_mult": 1.2,
		"outgoing_visibility_mult": 1.05
	},
	"attack": {
		"perception_mult": 0.8,
		"attack_range_mult": 1.2,
		"move_mult": 1.0,
		"guard_mult": 0.75,
		"attack_speed_mult": 1.1,
		"attack_force_mult": 1.2,
		"incoming_read_mult": 0.8,
		"outgoing_visibility_mult": 1.2
	},
	"speed": {
		"perception_mult": 0.9,
		"attack_range_mult": 1.25,
		"move_mult": 1.3,
		"guard_mult": 0.8,
		"attack_speed_mult": 1.3,
		"attack_force_mult": 0.9,
		"incoming_read_mult": 0.9,
		"outgoing_visibility_mult": 1.1
	},
	"stunned": {
		"perception_mult": 0.3,
		"attack_range_mult": 0.2,
		"move_mult": 0.1,
		"guard_mult": 0.2,
		"attack_speed_mult": 0.2,
		"attack_force_mult": 0.2,
		"incoming_read_mult": 0.3,
		"outgoing_visibility_mult": 1.3
	}
}

static func get_mult(state: String, key: String) -> float:
	if not STATES.has(state):
		state = DEFAULT_STATE
	return STATES[state].get(key, 1.0)