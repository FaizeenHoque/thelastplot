extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true # Replace with function body.

func _on_button_pressed() -> void:
	get_tree().paused = false
	queue_free() # Replace with function body.
