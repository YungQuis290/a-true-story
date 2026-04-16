extends Node
class_name AttackRayManager

# AttackRayManager is responsible for spawning and tracking attack rays.
#
# Keeping this separate allows you to:
# - centralize attack creation
# - later optimize performance (pooling, batching)
# - add global combat effects

func spawn_attack_ray(source: CombatActor, target: CombatActor, profile: AttackProfile):
	# Create a new attack ray and add it to the current scene.
	var ray := AttackRay.new()

	get_tree().current_scene.add_child(ray)

	# Initialize with attacker, target, and attack data.
	ray.setup(source, target, profile)

	return ray
