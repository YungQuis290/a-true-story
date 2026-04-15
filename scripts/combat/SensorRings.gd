extends Node2D
class_name SensorRings

# This node should be a child of a CombatActor.
# Example:
# Player
# └── SensorRings
#
# Because of that, we read the parent as the owning actor.
@onready var actor: CombatActor = get_parent() as CombatActor

func _process(_delta: float) -> void:
	# Redraw every frame so the ring sizes stay updated if stats change.
	queue_redraw()

func _draw() -> void:
	# If the parent is missing or not a CombatActor, do nothing.
	if actor == null:
		return

	# Blue ring = perception / danger sensing radius.
	var perception_ring_radius: float = CombatMath.perception_radius(
		actor.insight,
		actor.calm
	)

	# Red ring = real attack range.
	# IMPORTANT:
	# This uses the exact same math as the real attack check.
	var attack_ring_radius: float = CombatMath.effective_attack_range(
		actor.move_speed,
		actor.weapon_reach,
		20.0
	)

	# Draw the perception ring in blue.
	draw_arc(
		Vector2.ZERO,
		perception_ring_radius,
		0.0,
		TAU,
		96,
		Color(0.2, 0.5, 1.0, 0.9),
		2.0
	)

	# Draw the attack ring in red.
	draw_arc(
		Vector2.ZERO,
		attack_ring_radius,
		0.0,
		TAU,
		96,
		Color(1.0, 0.2, 0.2, 0.9),
		2.0
	)
