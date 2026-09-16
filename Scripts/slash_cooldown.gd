extends TextureProgressBar

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = PlayerStats.slash_cooldown
	if value <= 0:
		value = 1
