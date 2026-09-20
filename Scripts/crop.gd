extends Area2D

# Properties
var HEALTH = 100
const SPEED = 50.0
var grid_coord: Vector2i

var is_alive := true
var target = null
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death: AudioStreamPlayer2D = $Death
@onready var crop_break_particle: CPUParticles2D = $"Crop Break Particle Effect/CPUParticles2D"

func _ready() -> void:
	add_to_group("crops")
	z_index = 1

func _physics_process(delta: float) -> void:
	if is_alive:
		animated_sprite_2d.play("idle")

func take_damage(damage: int, attacker_position: Vector2, enemy: bool) -> void:
	HEALTH -= damage
	
	if HEALTH <= 0:
		if enemy:
			_die(attacker_position, false)
		else: 
			_die(attacker_position, true)
	else:
		animated_sprite_2d.modulate = Color(1, 1, 0)
		crop_break_particle.emitting = true
		
		await get_tree().create_timer(0.15).timeout
		if is_alive:
			animated_sprite_2d.modulate = Color(1, 1, 1)

func _die(attacker_position: Vector2, reward: bool) -> void:
	is_alive = false
	
	crop_break_particle.emitting = true
	animated_sprite_2d.play("death")
	
	death.pitch_scale = 1.75
	death.play()
	
	$hitbox.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "modulate:a", 0.0, 0.3)
	var mud_layer = get_tree().current_scene.get_node_or_null("Map/MudLayer")
	if mud_layer != null:
		mud_layer.set_cell(grid_coord, 0, Vector2i(0, 1))
		
	await tween.finished
	if reward:
		PlayerStats.nCrops += 1
		PlayerStats.money += 50
	queue_free()
	
