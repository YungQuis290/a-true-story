extends Resource
class_name AttackProfile

# AttackProfile defines the DATA for an attack type.
#
# This is NOT the attack execution logic. It is a reusable configuration
# that tells AttackRay how strong, fast, and visible an attack is.
#
# You will later create multiple profiles:
# - light_attack
# - heavy_attack
# - thrust
# - wide_swing
# - hidden_strike
#
# These profiles can be saved as .tres files in Godot for easy editing.

@export var base_force: float = 20.0
# Base damage/impact before scaling with stats and state.

@export var speed_scale: float = 1.0
# Multiplies the actor's attack speed when calculating ray velocity.

@export var visibility: float = 1.0
# How easy this attack is to detect.
# Higher = easier to detect sooner.

@export var stamina_cost: float = 15.0
# How much stamina is consumed when launching this attack.

@export var max_range: float = 300.0
# Maximum distance the attack ray can travel before disappearing.
