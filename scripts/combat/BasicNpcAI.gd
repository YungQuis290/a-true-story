extends Node
class_name BasicNpcAI

# This script should be attached as a child of TestNPC.
# Example:
# TestNPC
# └── BasicNpcAI

@onready var npc: CombatActor = get_parent() as CombatActor

# The AI needs to know who it is chasing/attacking.
var target: CombatActor

# How close the NPC wants to get before attacking.
var preferred_distance: float = 70.0

# How often the AI thinks.
var think_timer: float = 0.0
var think_interval: float = 0.2

# Blocking behavior.
var block_timer: float = 0.0
var block_duration: float = 0.4

func set_target(new_target: CombatActor) -> void:
	# Called by the scene controller after Player and NPC are loaded.
	target = new_target

func _process(delta: float) -> void:
	if npc == null:
		return

	if target == null:
		return

	# If dead, stop moving and blocking.
	if npc.health <= 0.0:
		npc.velocity = Vector2.ZERO
		npc.is_blocking = false
		return

	# Count down block timer.
	block_timer = max(0.0, block_timer - delta)

	if block_timer <= 0.0:
		npc.is_blocking = false

	# Think at intervals instead of every frame.
	think_timer -= delta

	if think_timer <= 0.0:
		think_timer = think_interval
		_think()

func _think() -> void:
	var distance_to_target: float = npc.global_position.distance_to(target.global_position)

	# If close and player has momentum, NPC sometimes blocks.
	if distance_to_target < 130.0 and target.momentum > 20.0 and npc.stamina > 15.0:
		npc.is_blocking = true
		block_timer = block_duration
		print(npc.actor_name, " chooses to block.")
		return

	# Check if NPC can attack the player.
	var in_attack_range: bool = CombatMath.target_in_attack_range(
		npc.global_position,
		target.global_position,
		npc.move_speed,
		npc.weapon_reach,
		20.0
	)

	if in_attack_range:
		npc.velocity = Vector2.ZERO
		npc.attack_target(target)
		return

	# Otherwise chase the player.
	var direction: Vector2 = (target.global_position - npc.global_position).normalized()
	npc.velocity = direction * npc.move_speed * 0.75
	npc.move_and_slide()