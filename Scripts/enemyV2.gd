extends CharacterBody2D

# Properties
var HEALTH = 100
const SPEED = 50.0

const STRENGHT: int = 25
const KNOCKBACK: int = 25

const ATTACK_WINDUP := 0.7
const ATTACK_RECOVERY := 0.4

var is_attacking := false
var attack_id := 0

var is_alive := true
var target = null
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var blood_particles: CPUParticles2D = $"Blood Particle Effect/CPUParticles2D"
@onready var attack_timer: Timer = $AttackTimer
@onready var range: Area2D = $range

func _physics_process(delta: float) -> void:
	if is_alive and is_attacking:
		pass
	elif is_alive and target:
		_chase(delta)
	elif is_alive and not target:
		animated_sprite_2d.play("idle")
	move_and_slide()

func _chase(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta

func take_damage(damage: int, attacker_position: Vector2) -> void:
	print("Damage taken")
	HEALTH -= damage
	take_damage_sound.play()
	
	if HEALTH <= 0:
		attack_id += 1
		is_attacking = false
		_die(attacker_position)
	else:
		attack_id += 1
		is_attacking = false
		attack_timer.stop()
		
		animated_sprite_2d.modulate = Color(1, 0, 0)
		blood_particles.emitting = true
		
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction * 50
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_position, 0.5)
		
		await get_tree().create_timer(0.15).timeout
		if is_alive:
			animated_sprite_2d.modulate = Color(1, 1, 1)
			attack_timer.start()

func _die(attacker_position: Vector2) -> void:
	is_alive = false
	
	var knockback_direction = (position - attacker_position).normalized()
	var target_position = position + knockback_direction * 200
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", target_position, 0.5)
	
	blood_particles.emitting = true
	animated_sprite_2d.play("death")
	
	take_damage_sound.pitch_scale = 1.75
	take_damage_sound.play()
	
	$innerSight/radius.set_deferred("disabled", true)
	$outerSight/radius.set_deferred("disabled", true)
	$hitbox.set_deferred("disabled", true)
	
	z_index = -100
	
func _on_inner_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body

func _on_outer_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target = null

func _on_range_body_entered(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		attack_timer.start()

func _on_range_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		attack_timer.stop()

func _on_attack_timer_timeout() -> void:
	if not is_alive or not target or is_attacking:
		return
	if not range.has_overlapping_bodies():
		attack_timer.stop()
		return
	_perform_attack()

func _perform_attack() -> void:
	is_attacking = true
	attack_timer.stop()

	attack_id += 1
	var current_attack_id = attack_id

	var direction = (target.position - position).normalized()

	var telegraph_tween = create_tween()
	telegraph_tween.set_trans(Tween.TRANS_QUAD)
	telegraph_tween.set_ease(Tween.EASE_OUT)
	telegraph_tween.tween_property(animated_sprite_2d, "scale", Vector2(0.85, 1.15), ATTACK_WINDUP * 0.6)
	telegraph_tween.tween_property(animated_sprite_2d, "scale", Vector2(1, 1), ATTACK_WINDUP * 0.4)

	animated_sprite_2d.modulate = Color(1, 0.9, 0.4)

	#var lunge_target = position + direction * LUNGE_DISTANCE
	#var windup_tween = create_tween()
	#windup_tween.set_trans(Tween.TRANS_QUAD)
	#windup_tween.set_ease(Tween.EASE_IN)
	#windup_tween.tween_property(self, "position", lunge_target, ATTACK_WINDUP)

	await get_tree().create_timer(ATTACK_WINDUP).timeout

	if current_attack_id != attack_id or not is_alive:
		animated_sprite_2d.modulate = Color(1, 1, 1)
		animated_sprite_2d.scale = Vector2(1, 1)
		return

	animated_sprite_2d.modulate = Color(1, 1, 1)

	if range.has_overlapping_bodies():
		for body in range.get_overlapping_bodies():
			if body.name == "Player":
				body.take_damage(STRENGHT, KNOCKBACK, position)
				_on_hit_landed()
				break

	await get_tree().create_timer(ATTACK_RECOVERY).timeout

	if current_attack_id != attack_id or not is_alive:
		return

	is_attacking = false

	if target and range.has_overlapping_bodies():
		attack_timer.start()
	
func _on_hit_landed() -> void:
	var punch_tween = create_tween()
	animated_sprite_2d.scale = Vector2(1.3, 0.7)
	punch_tween.tween_property(animated_sprite_2d, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_ELASTIC)
