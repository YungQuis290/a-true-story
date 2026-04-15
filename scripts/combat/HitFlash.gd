extends Node
class_name HitFlash

# This should be a child of a CombatActor.
@onready var actor: CombatActor = get_parent() as CombatActor

# We will flash the actor's ColorRect.
@onready var body_rect: ColorRect = actor.get_node("ColorRect") as ColorRect

var original_color: Color
var flash_timer: float = 0.0
var flash_duration: float = 0.12

func _ready() -> void:
	if body_rect != null:
		original_color = body_rect.color

func _process(delta: float) -> void:
	if flash_timer > 0.0:
		flash_timer -= delta

		if body_rect != null:
			body_rect.color = Color.WHITE

		if flash_timer <= 0.0 and body_rect != null:
			body_rect.color = original_color

func play_flash() -> void:
	# Called when the actor gets hit.
	flash_timer = flash_duration