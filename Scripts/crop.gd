extends Area2D

# Properties
var HEALTH = 100
const SPEED = 50.0

var is_alive := true
var target = null
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var crop_break_particle: CPUParticles2D = $"Crop Break Particle Effect/CPUParticles2D"

func _ready() -> void:
	z_index = -2

func _physics_process(delta: float) -> void:
	if is_alive:
		animated_sprite_2d.play("idle")

func take_damage(damage: int, attacker_position: Vector2) -> void:
	#print("Damage taken")
	HEALTH -= damage
	#take_damage_sound.play()
	
	if HEALTH <= 0:
		_die(attacker_position)
	else:
		animated_sprite_2d.modulate = Color(1, 1, 0)
		
		#var knockback_direction = (position - attacker_position).normalized()
		#var target_position = position + knockback_direction * 50
		#var tween = create_tween()
		#tween.set_ease(Tween.EASE_OUT)
		#tween.set_trans(Tween.TRANS_CUBIC)
		#tween.tween_property(self, "position", target_position, 0.5)
		
		crop_break_particle.emitting = true
		
		await get_tree().create_timer(0.15).timeout
		if is_alive:
			animated_sprite_2d.modulate = Color(1, 1, 1)
			
func _die(attacker_position: Vector2) -> void:
	is_alive = false
	
	#var knockback_direction = (position - attacker_position).normalized()
	#var target_position = position + knockback_direction * 200
	#var tween = create_tween()
	#tween.set_ease(Tween.EASE_OUT)
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(self, "position", target_position, 0.5)
	
	crop_break_particle.emitting = true
	animated_sprite_2d.play("death")
	
	#take_damage_sound.pitch_scale = 1.75
	#take_damage_sound.play()
	
	$hitbox.set_deferred("disabled", true)
	
	z_index = -3
	
