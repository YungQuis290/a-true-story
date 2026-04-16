extends Node2D
class_name AttackRay

# AttackRay is the CORE combat object.
#
# Instead of "instant hit if inside range",
# every attack becomes a traveling signal.
#
# This allows:
# - detection timing
# - reaction windows
# - dodging, blocking, clashing
# - hidden attacks
# - tactical spacing

var source: CombatActor
# The actor who launched the attack.

var target: CombatActor
# The intended target.

var profile: AttackProfile
# Data describing the attack type.

var velocity: Vector2
# Direction * speed.

var speed: float = 0.0
# Calculated from attacker stats and attack profile.

var detected: bool = false
# Has the defender recognized this attack yet?

var detection_progress: float = 0.0
# Builds up over time until detection happens.

func setup(_source, _target, _profile):
	# Initialize the attack ray.
	source = _source
	target = _target
	profile = _profile

	global_position = source.global_position

	var direction: Vector2 = (target.global_position - source.global_position).normalized()

	# Attack speed depends on actor stats AND state.
	speed = source.get_attack_speed() * profile.speed_scale

	velocity = direction * speed

func _process(delta):
	# If target disappears (dead, removed), remove the ray.
	if target == null:
		queue_free()
		return

	# Move the attack forward.
	global_position += velocity * delta

	# Check if the defender detects the attack.
	_process_detection(delta)

	# Check if we reached the target (impact).
	if global_position.distance_to(target.global_position) < 10.0:
		_resolve_hit()
		queue_free()

func _process_detection(delta):
	# Detection is NOT instant.
	# It depends on perception vs visibility.

	var perception: float = target.get_perception()
	var visibility: float = profile.visibility * source.get_visibility()

	# Incoming read multiplier from defender state.
	var read_mult: float = target.get_incoming_read()

	var strength: float = perception * read_mult

	# Build detection over time.
	detection_progress += (strength - visibility) * delta * 50.0

	if detection_progress >= 100.0 and not detected:
		detected = true
		print("ATTACK DETECTED by ", target.actor_name)

func _resolve_hit():
	# Resolve damage using force vs resist.

	var attack_force: float = source.get_attack_force(profile.base_force)
	var resist_force: float = target.get_resist_force()

	var net: float = attack_force - resist_force

	if net > 0.0:
		target.health -= net
		target.show_hit_feedback(net)

	print("HIT RESOLVED: ", net)
