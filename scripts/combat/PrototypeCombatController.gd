extends Node2D

# =========================
# SCENE REFERENCES
# =========================

# Player actor in the scene.
@onready var player: CombatActor = $Player

# Test enemy actor in the scene.
@onready var test_npc: CombatActor = $TestNPC

# Optional NPC AI node.
# This assumes your scene tree has:
# TestNPC
# └── BasicNpcAI
@onready var npc_ai: BasicNpcAI = $TestNPC/BasicNpcAI

# Attack ray manager.
# This script creates traveling attack rays instead of instant hits.
var attack_ray_manager: AttackRayManager

# Simple UI labels created in code.
var warning_label: Label
var reaction_label: Label
var state_label: Label

# Used so console messages only print when danger state changes.
var was_in_perception: bool = false
var was_in_attack_threat: bool = false


# =========================
# STARTUP
# =========================

func _ready() -> void:
	print("=== PROTOTYPE COMBAT START ===")

	# Create the attack ray manager in code so you do not need to add it manually.
	attack_ray_manager = AttackRayManager.new()
	add_child(attack_ray_manager)

	# Load character data from JSON.
	var player_data: Dictionary = CharacterLoader.load_character("res://data/characters/player_test.json")
	var npc_data: Dictionary = CharacterLoader.load_character("res://data/characters/npc_test.json")

	# Apply JSON data to both combat actors.
	player.apply_data(player_data)
	test_npc.apply_data(npc_data)

	# Give the NPC AI its target if the AI exists.
	if npc_ai != null:
		npc_ai.set_target(player)

	# Create simple debug UI.
	_create_ui()

	print("Player loaded: ", player.actor_name)
	print("NPC loaded: ", test_npc.actor_name)
	print("SPACE/ENTER = launch attack ray")
	print("D = dash")
	print("1 = passive")
	print("2 = defensive")
	print("3 = attack")
	print("4 = speed")
	print("5 = perceptive")
	print("6 = hidden")
	print("7 = stunned")


# =========================
# FRAME UPDATE
# =========================

func _process(_delta: float) -> void:
	_handle_player_movement()
	_update_danger_and_reaction()
	_update_debug_ui()


# =========================
# PLAYER MOVEMENT
# =========================

func _handle_player_movement() -> void:
	var input_vector: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1.0
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1.0
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1.0

	# Use state-aware movement if CombatActor has the function.
	# This lets speed/defensive/stunned states change actual movement.
	if player.has_method("get_effective_move_speed"):
		player.velocity = input_vector.normalized() * player.get_effective_move_speed()
	else:
		player.velocity = input_vector.normalized() * player.move_speed

	player.move_and_slide()


# =========================
# INPUT
# =========================

func _unhandled_input(event: InputEvent) -> void:
	# SPACE / ENTER launches an attack ray.
	if event.is_action_pressed("ui_accept"):
		_launch_player_attack_ray()

	# D key dashes in current movement direction.
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey

		if key_event.pressed and not key_event.echo:
			_handle_number_state_input(key_event)

			if key_event.keycode == KEY_D:
				_dash_player()


func _handle_number_state_input(key_event: InputEventKey) -> void:
	# Number keys let you test combat states quickly.
	# This is for prototype testing only.
	if key_event.keycode == KEY_1:
		player.set_state("passive")
		print("Player state: passive")

	if key_event.keycode == KEY_2:
		player.set_state("defensive")
		print("Player state: defensive")

	if key_event.keycode == KEY_3:
		player.set_state("attack")
		print("Player state: attack")

	if key_event.keycode == KEY_4:
		player.set_state("speed")
		print("Player state: speed")

	if key_event.keycode == KEY_5:
		player.set_state("perceptive")
		print("Player state: perceptive")

	if key_event.keycode == KEY_6:
		player.set_state("hidden")
		print("Player state: hidden")

	if key_event.keycode == KEY_7:
		player.set_state("stunned")
		print("Player state: stunned")


func _launch_player_attack_ray() -> void:
	# Create a default attack profile for now.
	# Later, replace this with actual light/heavy/special attacks.
	var profile: AttackProfile = AttackProfile.new()

	# Basic range check before launching.
	var distance_to_target: float = player.global_position.distance_to(test_npc.global_position)

	var allowed_range: float = player.weapon_reach + 300.0

	if player.has_method("get_effective_attack_range"):
		allowed_range = player.get_effective_attack_range()

	print("Distance to target: ", distance_to_target)
	print("Allowed attack ray range: ", allowed_range)

	if distance_to_target > allowed_range:
		print("Target out of attack ray range.")
		player.momentum = max(0.0, player.momentum - 2.0)
		return

	# Optional stamina/cooldown gate if CombatActor supports it.
	if player.has_method("can_launch_attack"):
		if not player.can_launch_attack(profile):
			return

	if player.has_method("spend_attack_cost"):
		player.spend_attack_cost(profile)

	# Spawn traveling attack ray.
	attack_ray_manager.spawn_attack_ray(player, test_npc, profile)

	print("Player launched attack ray.")


func _dash_player() -> void:
	var dash_direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		dash_direction.x += 1.0
	if Input.is_action_pressed("ui_left"):
		dash_direction.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		dash_direction.y += 1.0
	if Input.is_action_pressed("ui_up"):
		dash_direction.y -= 1.0

	# Default dash direction if no direction is held.
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT

	if player.has_method("try_dash"):
		player.try_dash(dash_direction)


# =========================
# UI CREATION
# =========================

func _create_ui() -> void:
	warning_label = Label.new()
	warning_label.position = Vector2(20, 20)
	add_child(warning_label)

	reaction_label = Label.new()
	reaction_label.position = Vector2(20, 50)
	add_child(reaction_label)

	state_label = Label.new()
	state_label.position = Vector2(20, 80)
	add_child(state_label)


# =========================
# DANGER / REACTION DISPLAY
# =========================

func _update_danger_and_reaction() -> void:
	var distance_to_npc: float = player.global_position.distance_to(test_npc.global_position)

	# Perception range.
	var player_perception_radius: float = player.get_perception()

	# Is NPC inside player's perception radius?
	var npc_in_perception: bool = distance_to_npc <= player_perception_radius

	# Is NPC close enough to threaten the player?
	var npc_attack_range: float = test_npc.weapon_reach + 300.0

	if test_npc.has_method("get_effective_attack_range"):
		npc_attack_range = test_npc.get_effective_attack_range()

	var npc_in_attack_threat: bool = distance_to_npc <= npc_attack_range

	if npc_in_perception:
		warning_label.text = "Danger sensed"
	else:
		warning_label.text = "No danger detected"

	if npc_in_attack_threat:
		var reaction_window_ms: float = _estimate_reaction_window_ms(
			player_perception_radius,
			distance_to_npc
		)

		reaction_label.text = "Reaction window estimate: " + str(int(reaction_window_ms)) + " ms"
	else:
		reaction_label.text = "No reaction window"

	# Print only on state transitions so console does not spam.
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


func _estimate_reaction_window_ms(perception_radius: float, distance_to_threat: float) -> float:
	# This is still an estimate.
	# The real reaction window will come from AttackRay:
	# detected_time -> impact_time.
	var distance_margin: float = max(0.0, perception_radius - distance_to_threat)
	var base_ms: float = 350.0

	return base_ms + distance_margin * 6.0


func _update_debug_ui() -> void:
	state_label.text = (
		"State: " + player.current_state
		+ " | HP: " + str(int(player.health))
		+ " | STA: " + str(int(player.stamina))
		+ " | MOM: " + str(int(player.momentum))
	)
