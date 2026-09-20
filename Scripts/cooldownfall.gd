extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_pressed() -> void:
	if PlayerStats.money >= 2000:
		PlayerStats.maxCooldown += 0.1 # Replace with function body.
		PlayerStats.money -= 2000
