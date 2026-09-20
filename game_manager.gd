extends Node

var game_time := "1:00"
var game_calendar := "Day 1"

var time := DAY_LENGTH * (1.0 / 24.0)
const DAY_LENGTH := 120.0
var nIterations = 1
var CurrentCycle := "Day"

@onready var canvas_modulate = get_tree().current_scene.get_node("CanvasModulate")
@onready var map = get_tree().current_scene.get_node("Map")
@onready var timer = get_tree().current_scene.get_node("Player/Timer/Label")

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
		crop.grid_coord = cell
		map.add_child(crop)

func _ready() -> void:
	generateWorld()

func _process(delta):
	time += delta

	if time >= DAY_LENGTH:
		time = 0.0

	var t = time / DAY_LENGTH
	
	var total_minutes = int(t * 24.0 * 60.0)
	var hours = total_minutes / 60
	var minutes = total_minutes % 60

	game_time = "%d:%02d" % [hours, minutes]

	if t < 0.15:
		var progress = t / 0.15
		canvas_modulate.color = night.lerp(morning, progress)
		CurrentCycle = "Morning"
	elif t < 0.35:
		var progress = (t - 0.15) / 0.20
		canvas_modulate.color = morning.lerp(day, progress)
		CurrentCycle = "Day"
	elif t < 0.50:
		var progress = (t - 0.35) / 0.15
		canvas_modulate.color = day.lerp(sunset, progress)
		CurrentCycle = "Sunset"
	else:
		var progress = (t - 0.50) / 0.50
		canvas_modulate.color = sunset.lerp(night, progress)
		CurrentCycle = "Night"
		nIterations += 1
		
	match CurrentCycle:
		"Morning":
			enemies_spawned = false
			PlayerStats.canFarm = true
			game_calendar = "Dawn " + str(nIterations)
			if nIterations > 0:
				var enemies = get_tree().get_nodes_in_group("enemy")
				for enemy in enemies:
					enemy.queue_free()
		"Day":
			game_calendar = "Dawn " + str(nIterations)
		"Sunset":
			PlayerStats.canFarm = false
			game_calendar = "Dusk " + str(nIterations)
			if nIterations == 3:
				#end da game
				if PlayerStats.nCrops > 50:
					get_tree().change_scene_to_file("res://Scenes/win.tscn") #win
				else:
					get_tree().change_scene_to_file("res://Scenes/lose.tscn")
			if not enemies_spawned:
				spawn_enemies()
				enemies_spawned = true
		"Night":
			game_calendar = "Dusk " + str(nIterations)
			if not enemies_spawned:
				spawn_enemies()
				enemies_spawned = true

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
