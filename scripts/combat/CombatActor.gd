extends CharacterBody2D
class_name CombatActor

# Stores the loaded character data from JSON
var actor_data: Dictionary = {}

# Basic combat values cached from the JSON file
var actor_name: String = "Unknown"
var health: float = 100.0
var stamina: float = 100.0
var momentum: float = 0.0
var calm: float = 50.0

# Core attributes
var might: float = 10.0
var endurance: float = 10.0
var dexterity: float = 10.0
var insight: float = 10.0

# Weapon values
var weapon_base_impact: float = 20.0
var weapon_reach: float = 40.0

# Simple movement speed for prototype
var move_speed: float = 150.0

# This is used to know if this actor is currently blocking
var is_blocking: bool = false

# This loads data into the actor from a Dictionary
func apply_data(data: Dictionary) -> void:
	actor_data = data
	
	# Read top-level values safely
	actor_name = data.get("display_name", "Unknown")
	
	# Read combat state
	var combat_state: Dictionary = data.get("combat_state", {})
	health = combat_state.get("health", 100)
	stamina = combat_state.get("stamina", 100)
	momentum = combat_state.get("momentum", 0)
	calm = combat_state.get("calm", 50)
	
	# Read core attributes
	var core: Dictionary = data.get("core_attributes", {})
	might = core.get("might", 10)
	endurance = core.get("endurance", 10)
	dexterity = core.get("dexterity", 10)
	insight = core.get("insight", 10)
	
	# Read weapon data
	var weapon: Dictionary = data.get("weapon", {})
	weapon_base_impact = weapon.get("base_impact", 20)
	weapon_reach = weapon.get("reach", 40)
	
	# Prototype movement speed uses dexterity for now
	move_speed = 100.0 + dexterity * 5.0

# This performs an attack calculation against another CombatActor
func attack_target(target: CombatActor) -> void:
	# Calculate attack force using your combat math system
	var atk: float = CombatMath.attack_force(
		weapon_base_impact,
		might,
		dexterity,
		momentum
	)
	
	# Blocking gives a better timing multiplier for now
	var timing_multiplier: float = 1.0
	if target.is_blocking:
		timing_multiplier = 1.5
	
	# Calculate target resist force
	var resist: float = CombatMath.resist_force(
		target.endurance,
		target.endurance,
		timing_multiplier
	)
	
	# Determine how much force gets through
	var net: float = CombatMath.net_force(atk, resist)
	
	# Calculate knockback
	var knockback: float = CombatMath.knockback_amount(net, target.endurance)
	
	# If attack beats defense, apply damage
	if net > 0:
		target.health -= net
		print(actor_name, " hits ", target.actor_name, " for ", net, " damage.")
	else:
		print(target.actor_name, " blocks the attack from ", actor_name)
	
	# Apply simple knockback in the x direction for testing
	target.position.x += knockback
	
	# Print result for debugging
	print("Attack Force: ", atk)
	print("Resist Force: ", resist)
	print("Net Force: ", net)
	print("Knockback: ", knockback)
	print(target.actor_name, " Health: ", target.health)
