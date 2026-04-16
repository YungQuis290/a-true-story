extends Node
class_name AttackRayManager

func spawn_attack_ray(source: CombatActor, target: CombatActor, profile: AttackProfile):
	var ray := AttackRay.new()
	get_tree().current_scene.add_child(ray)
	ray.setup(source, target, profile)