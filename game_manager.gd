extends Node

var time := 0.0
const DAY_LENGTH := 1200.0

var CurrentCycle := "Night"

@onready var canvas_modulate = get_tree().current_scene.get_node("CanvasModulate")

var night := Color("#394064")
var morning := Color("ffffffff")
var day := Color("#ffffff")
var sunset := Color("#d89b72")

func _process(delta):
	time += delta

	if time >= DAY_LENGTH:
		time = 0.0

	var t = time / DAY_LENGTH

	if t < 0.25:
		var progress = t / 0.25
		canvas_modulate.color = night.lerp(morning, progress)
		CurrentCycle = "Morning"

	elif t < 0.5:
		var progress = (t - 0.25) / 0.25
		canvas_modulate.color = morning.lerp(day, progress)
		CurrentCycle = "Day"

	elif t < 0.7:
		var progress = (t - 0.5) / 0.2
		canvas_modulate.color = day.lerp(sunset, progress)
		CurrentCycle = "Sunset"

	else:
		var progress = (t - 0.7) / 0.3
		canvas_modulate.color = sunset.lerp(night, progress)
		CurrentCycle = "Night"

	print("Current Time: ", t, " | Current Cycle: ", CurrentCycle)
