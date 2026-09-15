extends CharacterBody2D

var health = 100
const SPEED = 50.0
const KNOCKBACK_FORCE = 50

var is_alive := true
var target = null
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage

func _physics_process(delta: float) -> void:
	if is_alive and target:
		_attack(delta)
	elif is_alive and not target:
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

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	
	if abs(direction.x) > abs(direction.y):
		animated_sprite_2d.flip_h = direction.x < 0
		animated_sprite_2d.play("chase_right")
		
		last_direction = Vector2.RIGHT
	elif direction.y < 0:
		animated_sprite_2d.play("chase_up")
		
		last_direction = Vector2.UP
	else:
		animated_sprite_2d.play("chase_down")
		
		last_direction = Vector2.DOWN

func take_damage(damage: int, attacker_position: Vector2) -> void:
	health -= damage
	take_damage_sound.play()
	
	if health <= 0:
		_die()
	else:
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction * KNOCKBACK_FORCE
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_position, 0.5)

func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("death")
	
	take_damage_sound.pitch_scale = 0.5
	take_damage_sound.play()
	
	name = "DeadSkeleton"
	
	$innerSight/radius.set_deferred("disabled", true)
	$outerSight/radius.set_deferred("disabled", true)
	$hitbox.set_deferred("disabled", true)
	
func _on_inner_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body

func _on_outer_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target = null
