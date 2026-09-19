extends CharacterBody2D

var health = 100
const SPEED = 50.0

var is_alive := true
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var map = get_tree().current_scene.get_node("Map/TileMap")

func _ready() -> void:
	z_index = -2

func _physics_process(delta: float) -> void:
	if is_alive:
		match last_direction:
			Vector2.UP:
				animated_sprite_2d.play("idle_up")
			Vector2.DOWN:
				animated_sprite_2d.play("idle_down")
			Vector2.LEFT:
				animated_sprite_2d.flip_h = last_direction.x < 0
				animated_sprite_2d.play("idle_right")
			Vector2.RIGHT:
				animated_sprite_2d.play("idle_right")
	move_and_slide()
	var tile_pos = map.local_to_map(map.to_local($Center.global_position))
	var tile_data = map.get_cell_tile_data(tile_pos)

	if is_alive and tile_data and tile_data.get_custom_data("is_water"):
		_die()

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
	animated_sprite_2d.play("death")
	
	take_damage_sound.pitch_scale = 0.5
	take_damage_sound.play()
	
	$hitbox.set_deferred("disabled", true)
	
	z_index = -3
