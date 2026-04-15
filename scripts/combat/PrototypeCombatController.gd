extends Node2D

# Scene references.
@onready var player: CombatActor = $Player
@onready var test_npc: CombatActor = $TestNPC

# Simple UI labels created in code.
var warning_label: Label
var reaction_label: Label

# Used so console messages only print when state changes.
var was_in_perception: bool = false
var was_in_attack_threat: bool = false

func _ready() -> void:
	print("=== PROTOTYPE COMBAT START ===")

	# Load character JSON data.
	var player_data: Dictionary = CharacterLoader.load_character("res://data/characters/player_test.json")
	var npc_data: Dictionary = CharacterLoader.load_character("res://data/characters/npc_test.json")

	# Apply JSON data to the actors.
	player.apply_data(player_data)
	test_npc.apply_data(npc_data)

	print("Player loaded: ", player.actor_name)
	print("NPC loaded: ", test_npc.actor_name)

	_create_ui()

func _process(_delta: float) -> void:
	# Read movement input.
	var input_vector: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1.0
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1.0
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1.0

	# Move player.
	player.velocity = input_vector.normalized() * player.move_speed
	player.move_and_slide()

	# Hold Shift to make NPC block for testing.
	test_npc.is_blocking = Input.is_key_pressed(KEY_SHIFT)

	# Update danger / reaction labels.
	_update_danger_and_reaction()

	# Add resource display after reaction text.
	reaction_label.text += " | STA: " + str(int(player.stamina)) + " | MOM: " + str(int(player.momentum))

func _unhandled_input(event: InputEvent) -> void:
	# Space / Enter attacks.
	if event.is_action_pressed("ui_accept"):
		var in_range: bool = CombatMath.target_in_attack_range(
			player.global_position,
			test_npc.global_position,
			player.move_speed,
			player.weapon_reach,
			20.0
		)

		if in_range:
			player.attack_target(test_npc)
		else:
			print("Target out of range.")
			player.momentum = max(0.0, player.momentum - 2.0)

	# D key dashes.
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey

		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_D:
			var dash_direction: Vector2 = Vector2.ZERO

			if Input.is_action_pressed("ui_right"):
				dash_direction.x += 1.0
			if Input.is_action_pressed("ui_left"):
				dash_direction.x -= 1.0
			if Input.is_action_pressed("ui_down"):
				dash_direction.y += 1.0
			if Input.is_action_pressed("ui_up"):
				dash_direction.y -= 1.0

			# Default dash direction if no arrow key is held.
			if dash_direction == Vector2.ZERO:
				dash_direction = Vector2.RIGHT

			player.try_dash(dash_direction)

func _create_ui() -> void:
	# Top-left danger text.
	warning_label = Label.new()
	warning_label.position = Vector2(20, 20)
	add_child(warning_label)

	# Top-left reaction/resource text.
	reaction_label = Label.new()
	reaction_label.position = Vector2(20, 50)
	add_child(reaction_label)

func _update_danger_and_reaction() -> void:
	var distance_to_npc: float = player.global_position.distance_to(test_npc.global_position)

	# Blue ring logic: can the player sense the NPC?
	var npc_in_perception: bool = CombatMath.target_in_perception_range(
		player.global_position,
		test_npc.global_position,
		player.insight,
		player.calm
	)

	# Red threat logic: can the NPC threaten the player?
	var npc_in_attack_threat: bool = CombatMath.target_in_attack_range(
		test_npc.global_position,
		player.global_position,
		test_npc.move_speed,
		test_npc.weapon_reach,
		20.0
	)

	if npc_in_perception:
		warning_label.text = "Danger sensed"
	else:
		warning_label.text = "No danger detected"

	if npc_in_attack_threat:
		var player_perception_radius: float = CombatMath.perception_radius(player.insight, player.calm)
		var reaction_ms: float = CombatMath.reaction_window_ms(
			player_perception_radius,
			distance_to_npc,
			350.0
		)

		reaction_label.text = "Reaction window: " + str(int(reaction_ms)) + " ms"
	else:
		reaction_label.text = "No reaction window"

	# Print only when entering/leaving states.
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
