extends CharacterBody2D
class_name CombatActor

# Loaded character JSON data.
var actor_data: Dictionary = {}

# Identity.
var actor_name: String = "Unknown"

# Core combat state.
var health: float = 100.0
var stamina: float = 100.0
var max_stamina: float = 100.0
var momentum: float = 0.0
var calm: float = 50.0

# Core attributes.
var might: float = 10.0
var endurance: float = 10.0
var dexterity: float = 10.0
var insight: float = 10.0

# Weapon values.
var weapon_base_impact: float = 20.0
var weapon_reach: float = 40.0

# Movement.
var move_speed: float = 150.0

# Defensive state.
var is_blocking: bool = false

# Cooldowns.
# These count down every frame.
var attack_cooldown: float = 0.0
var block_cooldown: float = 0.0
var dash_cooldown: float = 0.0

# Costs.
const ATTACK_STAMINA_COST: float = 18.0
const BLOCK_STAMINA_DRAIN_PER_SECOND: float = 12.0
const DASH_STAMINA_COST: float = 25.0

# Cooldown lengths.
const ATTACK_COOLDOWN_TIME: float = 0.55
const DASH_COOLDOWN_TIME: float = 1.0

func _process(delta: float) -> void:
	# Cooldowns tick down toward 0.
	attack_cooldown = max(0.0, attack_cooldown - delta)
	block_cooldown = max(0.0, block_cooldown - delta)
	dash_cooldown = max(0.0, dash_cooldown - delta)

	# Stamina slowly regenerates when not blocking.
	if not is_blocking:
		stamina = min(max_stamina, stamina + 18.0 * delta)

	# Blocking drains stamina over time.
	if is_blocking:
		stamina = max(0.0, stamina - BLOCK_STAMINA_DRAIN_PER_SECOND * delta)

		# If stamina runs out, blocking breaks.
		if stamina <= 0.0:
			is_blocking = false

	# Momentum naturally decays slowly.
	momentum = max(0.0, momentum - 3.0 * delta)

func apply_data(data: Dictionary) -> void:
	actor_data = data
	actor_name = data.get("display_name", "Unknown")

	var combat_state: Dictionary = data.get("combat_state", {})
	health = combat_state.get("health", 100)
	stamina = combat_state.get("stamina", 100)
	max_stamina = stamina
	momentum = combat_state.get("momentum", 0)
	calm = combat_state.get("calm", 50)

	var core: Dictionary = data.get("core_attributes", {})
	might = core.get("might", 10)
	endurance = core.get("endurance", 10)
	dexterity = core.get("dexterity", 10)
	insight = core.get("insight", 10)

	var weapon: Dictionary = data.get("weapon", {})
	weapon_base_impact = weapon.get("base_impact", 20)
	weapon_reach = weapon.get("reach", 40)

	move_speed = 100.0 + dexterity * 5.0

func can_attack() -> bool:
	# You cannot attack if cooldown is active.
	if attack_cooldown > 0.0:
		print(actor_name, " cannot attack: attack cooldown active.")
		return false

	# You cannot attack if stamina is too low.
	if stamina < ATTACK_STAMINA_COST:
		print(actor_name, " cannot attack: not enough stamina.")
		return false

	return true

func attack_target(target: CombatActor) -> void:
	if not can_attack():
		return

	# Spend stamina and start cooldown.
	stamina -= ATTACK_STAMINA_COST
	attack_cooldown = ATTACK_COOLDOWN_TIME

	var atk: float = CombatMath.attack_force(
		weapon_base_impact,
		might,
		dexterity,
		momentum
	)

	# Blocking changes the defender timing multiplier.
	var timing_multiplier: float = 1.0
	if target.is_blocking:
		timing_multiplier = 1.5

	# Low stamina makes blocking weaker.
	var stamina_ratio: float = target.stamina / max(1.0, target.max_stamina)
	var guard_value: float = target.endurance * stamina_ratio

	var resist: float = CombatMath.resist_force(
		guard_value,
		target.endurance,
		timing_multiplier
	)

	var net: float = CombatMath.net_force(atk, resist)
	var knockback: float = CombatMath.knockback_amount(net, target.endurance)

	if net > 0.0:
		target.health -= net

		# Successful hit gives attacker momentum.
		momentum = min(100.0, momentum + 12.0)

		# Taking damage lowers defender momentum.
		target.momentum = max(0.0, target.momentum - 8.0)

		print(actor_name, " hits ", target.actor_name, " for ", net, " damage.")
	else:
		# Successful block gives defender momentum.
		target.momentum = min(100.0, target.momentum + 10.0)

		# Failed attack loses a little momentum.
		momentum = max(0.0, momentum - 4.0)

		print(target.actor_name, " blocks the attack from ", actor_name)

	# Better knockback direction: push target away from attacker.
	var knockback_direction: Vector2 = (target.global_position - global_position).normalized()
	target.global_position += knockback_direction * knockback

	print("Attack Force: ", atk)
	print("Resist Force: ", resist)
	print("Net Force: ", net)
	print("Knockback: ", knockback)
	print(actor_name, " Stamina: ", stamina)
	print(actor_name, " Momentum: ", momentum)
	print(target.actor_name, " Health: ", target.health)
	print(target.actor_name, " Stamina: ", target.stamina)
	print(target.actor_name, " Momentum: ", target.momentum)

func try_dash(direction: Vector2) -> void:
	if dash_cooldown > 0.0:
		print(actor_name, " cannot dash: dash cooldown active.")
		return

	if stamina < DASH_STAMINA_COST:
		print(actor_name, " cannot dash: not enough stamina.")
		return

	stamina -= DASH_STAMINA_COST
	dash_cooldown = DASH_COOLDOWN_TIME

	# Dash distance scales slightly with dexterity.
	var dash_distance: float = 90.0 + dexterity * 2.0
	global_position += direction.normalized() * dash_distance

	# Dashing can build small momentum if used actively.
	momentum = min(100.0, momentum + 3.0)

	print(actor_name, " dashed.")
	print(actor_name, " Stamina: ", stamina)