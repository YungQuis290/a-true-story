extends Node2D
class_name SensorRings

# The actor this ring belongs to.
# We will grab the parent because SensorRings will sit under Player.
@onready var actor: CombatActor = get_parent() as CombatActor

func _ready() -> void:
	# Tell Godot to draw this node.
	queue_redraw()

func _process(delta: float) -> void:
	# Redraw every frame so the rings update if stats change.
	queue_redraw()

func _draw() -> void:
	if actor == null:
		return
	
	# Perception ring:
	# This represents how far the character can sense danger.
	var perception_radius: float = CombatMath.perception_radius(
		actor.insight,
		actor.calm
	)
	
	# Speed/reach ring:
	# This represents how far the character can threaten or reach quickly.
	var speed_reach_radius: float = CombatMath.speed_reach_radius(
		actor.move_speed,
		actor.weapon_reach,
		40.0
	)
	
	# Draw perception ring in blue.
	draw_arc(
		Vector2.ZERO,
		perception_radius,
		0.0,
		TAU,
		96,
		Color(0.2, 0.5, 1.0, 0.9),
		2.0
	)
	
	# Draw speed/reach ring in red.
	draw_arc(
		Vector2.ZERO,
		speed_reach_radius,
		0.0,
		TAU,
		96,
		Color(1.0, 0.2, 0.2, 0.9),
		2.0
	)