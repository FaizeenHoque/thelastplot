extends CharacterBody2D

var HEALTH = 100
const SPEED = 50.0
const KNOCKBACK_FORCE = 50

var is_alive := true
var target = null
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage

func _physics_process(delta: float) -> void:
	#print("running")
	if is_alive and target:
		_attack(delta)
	elif is_alive and not target:
		animated_sprite_2d.play("idle")
	move_and_slide()

func _attack(delta: float) -> void:
	#print("Found target")
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play("chase")

func take_damage(damage: int, attacker_position: Vector2) -> void:
	print("Damage taken")
	HEALTH -= damage
	take_damage_sound.play()
	
	if HEALTH <= 0:
		_die()
	else:
		animated_sprite_2d.modulate = Color(1, 0, 0)
	
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction * KNOCKBACK_FORCE
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_position, 0.5)
		
		await get_tree().create_timer(0.15).timeout
		animated_sprite_2d.modulate = Color(1, 1, 1)

func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("death")
	
	take_damage_sound.pitch_scale = 1.75
	take_damage_sound.play()
	
	$innerSight/radius.set_deferred("disabled", true)
	$outerSight/radius.set_deferred("disabled", true)
	$hitbox.set_deferred("disabled", true)
	
func _on_inner_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body

func _on_outer_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target = null
