extends Node2D

@onready var player: CombatActor = $Player
@onready var test_npc: CombatActor = $TestNPC

# These are created at runtime so you do not have to manually add UI nodes in the editor.
var warning_label: Label
var reaction_label: Label

# Tracks danger state so the console does not spam every frame.
var was_in_perception: bool = false
var was_in_attack_threat: bool = false

func _ready() -> void:
	print("=== PROTOTYPE COMBAT START ===")

	# Load JSON data.
	var player_data: Dictionary = CharacterLoader.load_character("res://data/characters/player_test.json")
	var npc_data: Dictionary = CharacterLoader.load_character("res://data/characters/npc_test.json")

	player.apply_data(player_data)
	test_npc.apply_data(npc_data)

	print("Player loaded: ", player.actor_name)
	print("NPC loaded: ", test_npc.actor_name)

	# Build simple UI labels in code.
	_create_ui()

	# Place the labels in useful starting states.
	warning_label.text = "No danger detected"
	reaction_label.text = "No reaction window"

func _process(_delta: float) -> void:
	# ----------------------------
	# PLAYER MOVEMENT
	# ----------------------------
	var input_vector := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1.0
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1.0
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1.0

	player.velocity = input_vector.normalized() * player.move_speed
	player.move_and_slide()

	# NPC block test.
	test_npc.is_blocking = Input.is_key_pressed(KEY_SHIFT)

	# Check danger and reaction logic every frame.
	_update_danger_and_reaction()

func _unhandled_input(event: InputEvent) -> void:
	# Space / ui_accept = player attacks NPC if in the SAME range shown by the red ring.
	if event.is_action_pressed("ui_accept"):
		var in_range := CombatMath.target_in_attack_range(
			player.global_position,
			test_npc.global_position,
			player.move_speed,
			player.weapon_reach,
			20.0
		)

		var current_distance := player.global_position.distance_to(test_npc.global_position)
		var allowed_range := CombatMath.effective_attack_range(
			player.move_speed,
			player.weapon_reach,
			20.0
		)

		print("Distance to target: ", current_distance)
		print("Allowed attack range: ", allowed_range)

		if in_range:
			player.attack_target(test_npc)
		else:
			print("Target out of range.")

# ---------------------------------
# UI CREATION
# ---------------------------------

func _create_ui() -> void:
	warning_label = Label.new()
	warning_label.position = Vector2(20, 20)
	warning_label.text = ""
	add_child(warning_label)

	reaction_label = Label.new()
	reaction_label.position = Vector2(20, 50)
	reaction_label.text = ""
	add_child(reaction_label)

# ---------------------------------
# DANGER / REACTION LOGIC
# ---------------------------------

func _update_danger_and_reaction() -> void:
	var distance_to_npc := player.global_position.distance_to(test_npc.global_position)

	# 1) Danger warning from PERCEPTION ring.
	var npc_in_perception := CombatMath.target_in_perception_range(
		player.global_position,
		test_npc.global_position,
		player.insight,
		player.calm
	)

	# 2) Reaction window from ATTACK threat ring.
	# This means the enemy is close enough to threaten immediate attack pressure.
	var npc_in_attack_threat := CombatMath.target_in_attack_range(
		player.global_position,
		test_npc.global_position,
		test_npc.move_speed,
		test_npc.weapon_reach,
		20.0
	)

	# --- Danger warning label ---
	if npc_in_perception:
		warning_label.text = "Danger sensed"
	else:
		warning_label.text = "No danger detected"

	# --- Reaction window label ---
	if npc_in_attack_threat:
		var player_perception_radius := CombatMath.perception_radius(player.insight, player.calm)
		var reaction_ms := CombatMath.reaction_window_ms(
			player_perception_radius,
			distance_to_npc,
			350.0
		)

		reaction_label.text = "Reaction window: " + str(int(reaction_ms)) + " ms"
	else:
		reaction_label.text = "No reaction window"

	# --- Console edge-trigger logs so it does not spam ---
	if npc_in_perception and not was_in_perception:
		print("WARNING: NPC entered perception range.")

	if not npc_in_perception and was_in_perception:
		print("INFO: NPC left perception range.")

	if npc_in_attack_threat and not was_in_attack_threat:
		print("REACTION WINDOW OPENED.")

	if not npc_in_attack_threat and was_in_attack_threat:
		print("REACTION WINDOW CLOSED.")

	was_in_perception = npc_in_perception
	was_in_attack_threat = npc_in_attack_threat