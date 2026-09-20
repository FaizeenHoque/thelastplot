extends Node

func _on_pressed() -> void:
	if PlayerStats.money >= 2000 and PlayerStats.cooldown >= 0.3:
		PlayerStats.cooldown -= 0.1
		PlayerStats.money -= 2000
