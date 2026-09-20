extends CharacterBody2D

var health = 100
const SPEED = 50.0

var is_alive := true
var last_direction: Vector2 = Vector2.DOWN

var target_crop = null
var attack_cooldown := 0.0

const ATTACK_RANGE := 20.0
const ATTACK_DAMAGE := 10
const ATTACK_INTERVAL := 1.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var map = get_tree().current_scene.get_node("Map/TileMap")

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

			if abs(velocity.x) > abs(velocity.y):
				if velocity.x > 0:
					animated_sprite_2d.flip_h = false
					animated_sprite_2d.play("chase_side")
				else:
					animated_sprite_2d.flip_h = true
					animated_sprite_2d.play("chase_side")
			else:
				if velocity.y > 0:
					animated_sprite_2d.play("chase_down")
				else:
					animated_sprite_2d.play("chase_up")

		else:
			velocity = Vector2.ZERO

			if abs(last_direction.x) > abs(last_direction.y):
				animated_sprite_2d.flip_h = last_direction.x < 0
				animated_sprite_2d.play("idle_side")
			else:
				if last_direction.y > 0:
					animated_sprite_2d.play("idle_down")
				else:
					animated_sprite_2d.play("idle_up")

			if attack_cooldown <= 0:
				target_crop.take_damage(ATTACK_DAMAGE, global_position, true)
				attack_cooldown = ATTACK_INTERVAL

		var tile_pos = map.local_to_map(map.to_local($Center.global_position))
		var tile_data = map.get_cell_tile_data(tile_pos)

		if tile_data and tile_data.get_custom_data("is_water"):
			_die()

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
	health -= damage
	take_damage_sound.play()
	
	if health <= 0:
		_die()
	else:
		animated_sprite_2d.modulate = Color(1, 0, 0)
		
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction * 50
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_position, 0.5)
		
		await get_tree().create_timer(0.15).timeout
		animated_sprite_2d.modulate = Color(1, 1, 1)

func _die() -> void:
	is_alive = false
	velocity = Vector2.ZERO
	animated_sprite_2d.modulate = Color.WHITE

	if abs(last_direction.x) > abs(last_direction.y):
		animated_sprite_2d.flip_h = last_direction.x < 0
		animated_sprite_2d.play("death_side")
	else:
		if last_direction.y > 0:
			animated_sprite_2d.play("death_down")
		else:
			animated_sprite_2d.play("death_up")

	take_damage_sound.pitch_scale = 0.5
	take_damage_sound.play()

	$hitbox.set_deferred("disabled", true)

	z_index = -3
