extends CharacterBody2D
class_name CombatActor

# =========================
# CORE STATE
# =========================

var actor_name: String = "Unknown"

var health: float = 100.0
var max_health: float = 100.0

var stamina: float = 100.0
var max_stamina: float = 100.0

var momentum: float = 0.0
var calm: float = 50.0

# 🔥 NEW: posture system
var current_state: String = "passive"

# =========================
# ATTRIBUTES
# =========================

var might: float = 10.0
var endurance: float = 10.0
var dexterity: float = 10.0
var insight: float = 10.0
var technique: float = 10.0

# =========================
# WEAPON / MOVEMENT
# =========================

var weapon_base_impact: float = 20.0
var weapon_reach: float = 40.0
var move_speed: float = 150.0

# =========================
# COMBAT LOGIC HELPERS
# =========================

func get_perception() -> float:
	var base := insight * 6.0 + calm * 2.0 + technique * 1.5
	return base * ActorStateProfiles.get_value(current_state, "perception_mult")

func get_attack_speed() -> float:
	var base := 120.0 + dexterity * 4.0 + technique * 2.0
	return base * ActorStateProfiles.get_value(current_state, "attack_speed_mult")

func get_attack_force(base: float) -> float:
	return base \
		* (1.0 + might / 100.0) \
		* (1.0 + momentum / 200.0) \
		* ActorStateProfiles.get_value(current_state, "attack_force_mult")

func get_resist_force() -> float:
	return endurance * ActorStateProfiles.get_value(current_state, "guard_mult")

func get_visibility() -> float:
	return ActorStateProfiles.get_value(current_state, "outgoing_visibility_mult")

func get_incoming_read() -> float:
	return ActorStateProfiles.get_value(current_state, "incoming_read_mult")

# =========================
# FEEDBACK
# =========================

func show_hit_feedback(damage_amount: float) -> void:
	if has_node("HitFlash"):
		var hit_flash = get_node("HitFlash")
		if hit_flash.has_method("play_flash"):
			hit_flash.play_flash()

	if ClassDB.class_exists("FloatingText"):
		var txt = FloatingText.new()
		get_tree().current_scene.add_child(txt)
		txt.setup("-" + str(int(damage_amount)), global_position)