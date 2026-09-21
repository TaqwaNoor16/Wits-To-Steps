extends Node3D

@onready var light1: AreaLight3D = $FloorLight1
@onready var light2: AreaLight3D = $FloorLight2
@onready var light3: AreaLight3D = $FloorLight3

@export var change_speed: float = 1.0

var timer: float = 0.0


func _ready() -> void:
	change_floor_colors()


func _process(delta: float) -> void:
	timer += delta

	if timer >= change_speed:
		timer = 0.0
		change_floor_colors()


func change_floor_colors() -> void:

	# Random color for each floor light
	light1.light_color = random_floor_color()
	light2.light_color = random_floor_color()
	light3.light_color = random_floor_color()

	# Softer brightness
	light1.light_energy = randf_range(1.5, 3.0)
	light2.light_energy = randf_range(1.5, 3.0)
	light3.light_energy = randf_range(1.5, 3.0)


func random_floor_color() -> Color:

	# Softer / lighter colors
	var colors = [
		Color("#ff75bd"), # Light pink
		Color("#c47aff"), # Light purple
		Color("#75eaff"), # Light cyan
		Color("#789cff"), # Light blue
		Color("#ff7777"), # Light red
		Color("#ffb45c")  # Light orange
	]

	return colors.pick_random()
