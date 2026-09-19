extends Node

var time := 0.0
const DAY_LENGTH := 1200.0

var CurrentCycle := "Night"

@onready var canvas_modulate = get_tree().current_scene.get_node("CanvasModulate")
var cropScene = preload("res://Scenes/crop.tscn")

var night := Color("#394064")
var morning := Color("ffffffff")
var day := Color("#ffffff")
var sunset := Color("#d89b72")


func generateWorld():
	for x in range(10):
		for y in range(10):
			var crop = cropScene.instantiate()
			crop.position = Vector2((x - 2) * 40, (y - 2) * 40)
			add_child(crop)

func _ready() -> void:
	generateWorld()

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
		
	match CurrentCycle:
		"Morning": pass
		"Day": pass
		"Sunset": pass
		"Night": pass

	#print("Current Time: ", t, " | Current Cycle: ", CurrentCycle)
