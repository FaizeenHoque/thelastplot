extends CharacterBody2D

const SPEED = 150.0

var last_direction: Vector2 = Vector2.DOWN
var is_slashing: bool = false

var range_offset: Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sword: AudioStreamPlayer2D = $SwingSword
@onready var range: Area2D = $Range

func _ready() -> void:
	range_offset = range.position

func _physics_process(delta: float) -> void:
	# Disable range until an attack is triggered
	range.monitoring = false
	
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
		
		updateRangeOffset()
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
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down") 

func slash() -> void:
	is_slashing = true
	range.monitoring = true
	swing_sword.play()
	play_animation("slash", last_direction)	

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_slashing:
		is_slashing = false

func updateRangeOffset() -> void:
	var x := range_offset.x
	var y := range_offset.y
	
	match last_direction:
		Vector2.LEFT:
			range.position = Vector2(-x, y)
		Vector2.RIGHT:
			range.position = Vector2(x, y)
		Vector2.UP:
			range.position = Vector2(y-2.5, -x)
		Vector2.DOWN:
			range.position = Vector2(-y-3.5, x)

func _on_range_body_entered(body: Node2D) -> void:
	if is_slashing and body.name.begins_with("Skeleton"):
		print("Hit")
