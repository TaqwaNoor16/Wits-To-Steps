extends Node3D

@onready var beam1: MeshInstance3D = $Beam1
@onready var beam2: MeshInstance3D = $Beam2
@onready var beam3: MeshInstance3D = $Beam3
@onready var beam4: MeshInstance3D = $Beam4

@onready var glow1: OmniLight3D = $Glow1
@onready var glow2: OmniLight3D = $Glow2
@onready var glow3: OmniLight3D = $Glow3
@onready var glow4: OmniLight3D = $Glow4


@export var change_speed: float = 0.45

var timer: float = 0.0


func _ready() -> void:

	make_material_unique(beam1)
	make_material_unique(beam2)
	make_material_unique(beam3)
	make_material_unique(beam4)

	randomize_beams()


func _process(delta: float) -> void:

	timer += delta

	if timer >= change_speed:

		timer = 0.0

		randomize_beams()


func make_material_unique(beam: MeshInstance3D) -> void:

	var material = beam.get_active_material(0)

	if material:

		beam.material_override = material.duplicate()


func randomize_beams() -> void:

	# Each beam gets its own color
	var color1 = random_neon_color()
	var color2 = random_neon_color()
	var color3 = random_neon_color()
	var color4 = random_neon_color()


	# Change beam colors
	set_beam_color(beam1, color1)
	set_beam_color(beam2, color2)
	set_beam_color(beam3, color3)
	set_beam_color(beam4, color4)


	# Actual lights use SAME colors
	glow1.light_color = color1
	glow2.light_color = color2
	glow3.light_color = color3
	glow4.light_color = color4


	# Random brightness
	glow1.light_energy = randf_range(1.5, 3.5)
	glow2.light_energy = randf_range(1.5, 3.5)
	glow3.light_energy = randf_range(1.5, 3.5)
	glow4.light_energy = randf_range(1.5, 3.5)


	# Spread beams apart
	move_beam(
		beam1,
		Vector3(-4.5, 5.0, 0.0),
		randf_range(-35.0, -20.0)
	)

	move_beam(
		beam2,
		Vector3(-1.5, 5.0, 0.0),
		randf_range(-18.0, -5.0)
	)

	move_beam(
		beam3,
		Vector3(1.5, 5.0, 0.0),
		randf_range(5.0, 18.0)
	)

	move_beam(
		beam4,
		Vector3(4.5, 5.0, 0.0),
		randf_range(20.0, 35.0)
	)


	# Random flashing
	beam1.visible = randf() > 0.15
	beam2.visible = randf() > 0.15
	beam3.visible = randf() > 0.15
	beam4.visible = randf() > 0.15


	# Match glow visibility with beams
	glow1.visible = beam1.visible
	glow2.visible = beam2.visible
	glow3.visible = beam3.visible
	glow4.visible = beam4.visible


func move_beam(
	beam: MeshInstance3D,
	start_position: Vector3,
	angle: float
) -> void:

	beam.position = start_position

	var target_rotation = Vector3(
		randf_range(-8.0, 8.0),
		randf_range(-10.0, 10.0),
		angle
	)

	var tween = create_tween()

	tween.tween_property(
		beam,
		"rotation_degrees",
		target_rotation,
		change_speed
	)


func set_beam_color(
	beam: MeshInstance3D,
	color: Color
) -> void:

	var material = beam.material_override

	if material is StandardMaterial3D:

		material.albedo_color = color


func random_neon_color() -> Color:

	var colors = [
		Color("#ff008c"), # Pink
		Color("#ff00ff"), # Magenta
		Color("#9d00ff"), # Purple
		Color("#00eaff"), # Cyan
		Color("#0066ff"), # Blue
		Color("#00ff88"), # Green
		Color("#ffee00"), # Yellow
		Color("#ff3300")  # Orange
	]

	return colors.pick_random()
