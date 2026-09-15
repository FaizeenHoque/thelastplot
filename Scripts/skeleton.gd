extends CharacterBody2D

const SPEED = 50.0
var target = null

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if target:
		_attack(delta)
	move_and_slide()

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	
	if abs(direction.x) > abs(direction.y):
		animated_sprite_2d.play("chase_right")
		animated_sprite_2d.flip_h = direction.x < 0
	elif direction.y < 0:
		animated_sprite_2d.play("chase_up")
	else:
		animated_sprite_2d.play("chase_down")

func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		print(body)
