extends Node

func _on_pressed() -> void:
	if PlayerStats.money >= 2000:
		PlayerStats.maxCooldown += 0.1 # Replace with function body.
		PlayerStats.money -= 2000
