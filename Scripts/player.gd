extends CharacterBody2D

const SPEED = 150.0

var last_direction: Vector2 = Vector2.DOWN
var is_slashing: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Slash") and not is_slashing:
		slash()
	
	# skip movement if attacking
	if is_slashing:
		velocity = Vector2.ZERO
		return
		
	process_movement()
	move_and_slide()

func process_movement() -> void:
	var direction := Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO

	process_animation(last_direction)

func process_animation(direction: Vector2) -> void:
	if is_slashing:
		return
	if velocity != Vector2.ZERO:
		play_animation("walk", direction)
	else:
		play_animation("idle", direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0 
		animated_sprite_2d.play(prefix + "_left")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down") 

func slash() -> void:
	is_slashing = true
	play_animation("slash", last_direction)	
	print("Attack")

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_slashing:
		is_slashing = false
