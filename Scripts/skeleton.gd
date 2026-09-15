extends CharacterBody2D

const SPEED = 50.0

var target = null
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if target:
		_attack(delta)
	else:
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

func _on_inner_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		print(body)

func _on_outer_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target = null
