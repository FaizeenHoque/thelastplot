extends CharacterBody2D

var HEALTH = 100
const SPEED = 50.0

var is_alive := true
var target_crop = null
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var blood_particles: CPUParticles2D = $"Blood Particle Effect/CPUParticles2D"
@onready var map = get_tree().current_scene.get_node("Map/TileMap")

var attack_cooldown := 0.0

const ATTACK_RANGE := 20.0
const ATTACK_DAMAGE := 10
const ATTACK_INTERVAL := 1.0

func _ready() -> void:
	z_index = -2

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	attack_cooldown -= delta

	if not is_instance_valid(target_crop):
		target_crop = get_nearest_crop()

	if target_crop:
		var distance = global_position.distance_to(target_crop.global_position)

		if distance > ATTACK_RANGE:
			velocity = global_position.direction_to(target_crop.global_position) * SPEED
			last_direction = velocity.normalized()
			move_and_slide()
			animated_sprite_2d.play("idle")

		else:
			velocity = Vector2.ZERO
			animated_sprite_2d.play("idle")

			if attack_cooldown <= 0:
				target_crop.take_damage(ATTACK_DAMAGE, global_position, true)
				attack_cooldown = ATTACK_INTERVAL

	var tile_pos = map.local_to_map(map.to_local($Center.global_position))
	var tile_data = map.get_cell_tile_data(tile_pos)

	if tile_data and tile_data.get_custom_data("is_water"):
		_die(global_position)

func get_nearest_crop():
	var crops = get_tree().current_scene.get_tree().get_nodes_in_group("crops")

	var nearest = null
	var nearest_distance = INF

	for crop in crops:
		if not is_instance_valid(crop):
			continue

		var distance = global_position.distance_to(crop.global_position)

		if distance < nearest_distance:
			nearest = crop
			nearest_distance = distance

	return nearest

func take_damage(damage: int, attacker_position: Vector2) -> void:
	print("Damage taken")
	HEALTH -= damage
	take_damage_sound.play()
	
	if HEALTH <= 0:
		_die(attacker_position)
	else:
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
			
func _die(attacker_position: Vector2) -> void:
	is_alive = false
	velocity = Vector2.ZERO
	animated_sprite_2d.modulate = Color(1, 1, 1)
	
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
	
	$hitbox.set_deferred("disabled", true)
	
	z_index = -3
