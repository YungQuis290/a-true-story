extends Label
class_name ActorNameplate

# This label should be a child of a CombatActor.
@onready var actor: CombatActor = get_parent() as CombatActor

func _process(_delta: float) -> void:
	if actor == null:
		return

	# Always show the actor's current name above their head.
	text = actor.actor_name

	# Keep the label positioned above the character body.
	position = Vector2(-40, -70)