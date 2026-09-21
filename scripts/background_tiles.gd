extends Control



@export var tile_size: float = 90.0
@export var gap: float = 3.0

# How often the colors change
@export var color_change_speed: float = 1.2

# How slowly they fade into the new color
@export var fade_speed: float = 1.0


var tiles: Array[ColorRect] = []

var timer: float = 0.0



var tile_colors = [
	Color("#ff4fa3"), # Pink
	Color("#d94cff"), # Purple Pink
	Color("#a855f7"), # Purple
	Color("#8b5cf6"), # Violet
	Color("#ff70b7"), # Light Pink
	Color("#c026d3"), # Dark Pink/Purple

	Color("#ff1493"), # Hot Pink

	Color("#3b82f6"), # Blue
	Color("#00eaff"), # Cyan

	Color("#00ff88"), # Green
	Color("#84ff00"), # Lime

	Color("#ffee00"), # Yellow
	Color("#ff9500"), # Orange

	Color("#ff3b30")  # Red
]


func _ready() -> void:

	create_tiles()



func _process(delta: float) -> void:

	timer += delta


	if timer >= color_change_speed:

		timer = 0.0

		change_tile_colors()


func create_tiles() -> void:

	var columns: int = int(ceil(size.x / tile_size)) + 1
	var rows: int = int(ceil(size.y / tile_size)) + 1


	for row in range(rows):

		for column in range(columns):

			var tile := ColorRect.new()


			# Don't block PLAY button
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE


			tile.position = Vector2(
				column * tile_size,
				row * tile_size
			)


			tile.size = Vector2(
				tile_size - gap,
				tile_size - gap
			)


			# Start as pink/purple checkerboard
			if (row + column) % 2 == 0:

				tile.color = tile_colors[0]

			else:

				tile.color = tile_colors[2]


			add_child(tile)

			tiles.append(tile)



func change_tile_colors() -> void:

	for tile in tiles:

		var new_color: Color = tile_colors.pick_random()


		var tween = create_tween()


		tween.tween_property(
			tile,
			"color",
			new_color,
			fade_speed
		)
