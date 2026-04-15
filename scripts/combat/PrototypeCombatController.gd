extends Node2D

# References to the two actors in the scene
@onready var player: CombatActor = $Player
@onready var test_npc: CombatActor = $TestNPC

func _ready() -> void:
	print("=== PROTOTYPE COMBAT START ===")
	
	# Load JSON data into the two actors
	var player_data: Dictionary = CharacterLoader.load_character("res://data/characters/player_test.json")
	var npc_data: Dictionary = CharacterLoader.load_character("res://data/characters/npc_test.json")
	
	player.apply_data(player_data)
	test_npc.apply_data(npc_data)
	
	print("Player loaded: ", player.actor_name)
	print("NPC loaded: ", test_npc.actor_name)
	print("Press SPACE to attack.")
	print("Hold SHIFT to block with the NPC.")

func _process(delta: float) -> void:
	# Very simple player movement for testing
	var input_vector := Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	
	player.velocity = input_vector.normalized() * player.move_speed
	player.move_and_slide()
	
	# NPC block test
	test_npc.is_blocking = Input.is_key_pressed(KEY_SHIFT)

func _unhandled_input(event: InputEvent) -> void:
	# Press space to attack the NPC if close enough
	if event.is_action_pressed("ui_accept"):
		var distance_to_target: float = player.global_position.distance_to(test_npc.global_position)
		
		print("Distance to target: ", distance_to_target)
		print("Weapon reach: ", player.weapon_reach)
		
		if distance_to_target <= player.weapon_reach + 20.0:
			player.attack_target(test_npc)
		else:
			print("Target out of range.")