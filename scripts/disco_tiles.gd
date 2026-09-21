extends Node3D

@export var rows: int = 6
@export var columns: int = 8

@export var tile_size: float = 1.0
@export var gap: float = 0.08

# How fast the floor changes colors
@export var color_change_speed: float = 0.5

@onready var template: MeshInstance3D = $Tile

var tiles: Array[MeshInstance3D] = []
var timer: float = 0.0


func _ready() -> void:
	create_tiles()


func _process(delta: float) -> void:
	timer += delta

	if timer >= color_change_speed:
		timer = 0.0
		randomize_tiles()




func create_tiles() -> void:

	# Hide original Tile.
	# It is only used as the template.
	template.visible = false

	tiles.clear()


	# Calculate total grid size
	var floor_width = (columns - 1) * (tile_size + gap)
	var floor_depth = (rows - 1) * (tile_size + gap)


	for row in range(rows):

		for column in range(columns):

			# Copy original Tile
			var tile: MeshInstance3D = template.duplicate()

			tile.visible = true



			var old_material = tile.get_active_material(0)

			if old_material:
				tile.material_override = old_material.duplicate()



			var x = column * (tile_size + gap)
			var z = row * (tile_size + gap)


			# Center entire floor
			x -= floor_width / 2.0
			z -= floor_depth / 2.0


			tile.position = Vector3(
				x,
				0.08,
				z
			)


			# Add tile
			add_child(tile)

			tiles.append(tile)


	# Give every tile a starting color
	randomize_tiles()




func randomize_tiles() -> void:
	for tile in tiles:
		var material = tile.material_override

		if material is StandardMaterial3D:
			var color = random_disco_color()

			# Dim the tile
			color *= 0.80

			material.albedo_color = color


# ==========================================
# RANDOM DISCO COLORS
# ==========================================

func random_disco_color() -> Color:

	var colors = [

		Color("#ff008c"), # Hot pink

		Color("#ff00ff"), # Magenta

		Color("#8c00ff"), # Purple

		Color("#00eaff"), # Cyan

		Color("#0066ff"), # Blue

		Color("#00ff88"), # Green

		Color("#ffee00"), # Yellow

		Color("#ff5500")  # Orange
	]

	return colors.pick_random()
