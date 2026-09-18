extends Node
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.frame = 0
	sprite.stop()

func chop() -> void:
	collision.set_deferred("disabled", true)
	sprite.play("chop")
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	
	tween.finished.connect(queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
