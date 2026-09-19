extends Node

var time := 300.0 # Starting the game bright and shiny to let the player harvest some crops (before defending them)
const DAY_LENGTH := 1200.0
var nIterations = 1
var CurrentCycle := "Day"

@onready var canvas_modulate = get_tree().current_scene.get_node("CanvasModulate")
@onready var map = get_tree().current_scene.get_node("Map")

@onready var spawn_points = map.get_children().filter(func(node): return node.name.begins_with("SpawnLocation"))
var enemies_spawned := false

var cropScene = preload("res://Scenes/crop.tscn")
var slime = preload("res://Scenes/slime.tscn")
var skeleton = preload("res://Scenes/skeleton.tscn")
var dog = preload("res://Scenes/dog.tscn")

var night := Color("#394064")
var morning := Color("ffffffff")
var day := Color("#ffffff")
var sunset := Color("#d89b72")

func generateWorld():
	var tilemap = get_tree().current_scene.get_node("Map/MudLayer")
	
	var painted_cells = tilemap.get_used_cells()
	
	for cell in painted_cells:
		var crop = cropScene.instantiate()
		
		crop.global_position = tilemap.map_to_local(cell)
		map.add_child(crop)

func _ready() -> void:
	print("ready")
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
		"Morning":
			enemies_spawned = false
		"Day":
			pass
			#if nIterations == 1:
				#generateWorld()
		"Sunset":
			pass
		"Night":
			if not enemies_spawned:
				spawn_enemies()
				enemies_spawned = true
			nIterations += 1

	#print("Current Time: ", t, " | Current Cycle: ", CurrentCycle)
	
func spawn_enemies():
	var enemies = [slime, skeleton, dog]
	var available_points = spawn_points.duplicate()

	for i in range(min(5, available_points.size())):
		var spawn_point = available_points.pick_random()
		available_points.erase(spawn_point)

		var enemy = enemies.pick_random().instantiate()
		enemy.global_position = spawn_point.global_position
		get_tree().current_scene.add_child(enemy)
