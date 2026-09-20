extends Node

func _on_pressed() -> void:
	if PlayerStats.money >= 1000:
		PlayerStats.SLASH_STRENGTH += 20
		PlayerStats.money -= 1000
