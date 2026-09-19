extends CharacterBody2D

var SPEED = 150.0
var SLASH_STRENGTH = 20


var MAX_HEALTH: int
var health: int
var nCrops: int = 0

var last_direction: Vector2 = Vector2.DOWN
var is_slashing: bool = false

var range_offset: Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sword: AudioStreamPlayer2D = $SwingSword
@onready var hurt: AudioStreamPlayer2D = $Hurt
@onready var score: Label = $HUD/nCrops/Label
@onready var moni: Label = $HUD/Coin/Label
@onready var range: Area2D = $Range
@onready var attack_cooldown: Timer = $AttackCooldown

func _ready() -> void:
	health = PlayerStats.health
	MAX_HEALTH = PlayerStats.max_health
	
	range_offset = range.position

func _physics_process(delta: float) -> void:
	# Disable range until an attack is triggered
	range.monitoring = false
	score.text = str(PlayerStats.nCrops)
	moni.text = str(PlayerStats.money)
	PlayerStats.slash_cooldown = attack_cooldown.time_left
	
	if Input.is_action_just_pressed("Slash") and not is_slashing and attack_cooldown.is_stopped():
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

#func take_damage(amount: int, knockback: int, attacker_position: Vector2) -> void:
	#health -= amount
	#hurt.play()
	#PlayerStats.health = health
	#
	#var knockback_direction = (position - attacker_position).normalized()
	#var target_position = position + knockback_direction * knockback
	#var tween = create_tween()
	#tween.set_ease(Tween.EASE_OUT)
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(self, "position", target_position, 0.5)

func slash() -> void:
	is_slashing = true
	range.monitoring = true
	attack_cooldown.start()
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
	if is_slashing and body.is_in_group("enemy"):
		body.take_damage(SLASH_STRENGTH, position)

func _on_range_area_entered(area: Area2D) -> void:
	if is_slashing and area.has_method("take_damage") and PlayerStats.canFarm:
		area.take_damage(SLASH_STRENGTH, position)
