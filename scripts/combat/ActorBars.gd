extends Node2D
class_name ActorBars

# This script should be attached under a CombatActor.
# Example:
# Player
# └── ActorBars

@onready var actor: CombatActor = get_parent() as CombatActor

var bar_width: float = 50.0
var bar_height: float = 5.0

func _process(_delta: float) -> void:
	# Redraw every frame because health, stamina, and momentum can change.
	queue_redraw()

func _draw() -> void:
	if actor == null:
		return

	# Draw bars slightly above the character.
	var start_pos: Vector2 = Vector2(-25, -45)

	# Health bar.
	_draw_bar(start_pos, actor.health, 120.0, Color.RED)

	# Stamina bar.
	_draw_bar(start_pos + Vector2(0, 8), actor.stamina, actor.max_stamina, Color.GREEN)

	# Momentum bar.
	_draw_bar(start_pos + Vector2(0, 16), actor.momentum, 100.0, Color.YELLOW)

func _draw_bar(pos: Vector2, value: float, max_value: float, fill_color: Color) -> void:
	# Prevent divide-by-zero.
	var safe_max: float = max(1.0, max_value)

	# Convert value to 0.0 - 1.0.
	var ratio: float = clamp(value / safe_max, 0.0, 1.0)

	# Background bar.
	draw_rect(
		Rect2(pos, Vector2(bar_width, bar_height)),
		Color(0.1, 0.1, 0.1, 0.9),
		true
	)

	# Filled bar.
	draw_rect(
		Rect2(pos, Vector2(bar_width * ratio, bar_height)),
		fill_color,
		true
	)
