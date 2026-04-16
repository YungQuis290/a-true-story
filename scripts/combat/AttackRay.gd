extends Node2D
class_name AttackRay

var source: CombatActor
var target: CombatActor
var profile: AttackProfile

var velocity: Vector2
var speed: float = 0.0

var detected: bool = false
var detection_progress: float = 0.0

func setup(_source, _target, _profile):
	source = _source
	target = _target
	profile = _profile
	
	global_position = source.global_position
	
	var dir: Vector2 = (target.global_position - source.global_position).normalized()
	
	speed = source.get_attack_speed() * profile.speed_scale
	velocity = dir * speed

func _process(delta):
	if target == null:
		queue_free()
		return
	
	# Move ray
	global_position += velocity * delta
	
	# Detection check
	_process_detection(delta)
	
	# Impact check
	if global_position.distance_to(target.global_position) < 10.0:
		_resolve_hit()
		queue_free()

func _process_detection(delta):
	var perception := target.get_perception()
	var visibility := profile.visibility * source.get_visibility()
	
	var strength := perception * target.get_incoming_read()
	
	detection_progress += (strength - visibility) * delta * 50.0
	
	if detection_progress >= 100.0 and not detected:
		detected = true
		print("ATTACK DETECTED")

func _resolve_hit():
	var atk := source.get_attack_force(profile.base_force)
	var res := target.get_resist_force()
	
	var net := atk - res
	
	if net > 0:
		target.health -= net
		target.apply_hit_feedback(net)