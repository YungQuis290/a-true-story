extends Label
class_name FloatingText

# How fast the text moves upward.
var float_speed: float = 35.0

# How long the text stays alive.
var lifetime: float = 0.8

func setup(message: String, start_position: Vector2) -> void:
	text = message
	global_position = start_position

func _process(delta: float) -> void:
	# Move upward.
	position.y -= float_speed * delta

	# Fade out over time.
	lifetime -= delta
	modulate.a = clamp(lifetime / 0.8, 0.0, 1.0)

	# Remove when finished.
	if lifetime <= 0.0:
		queue_free()