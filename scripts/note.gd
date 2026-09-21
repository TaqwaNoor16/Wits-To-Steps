extends Control




@export var speed: float = 250.0
@export var hit_range: float = 55.0

var hit_y: float = 0.0



var lane: int = 0




var heel_bar: ProgressBar
var hit_text: Label

var combo_label: Label
var points_label: Label


var finished: bool = false




static var combo: int = 0
static var total_points: int = 0



func _ready() -> void:

	add_to_group("rhythm_notes")


	heel_bar = get_tree().current_scene.get_node(
		"UI/RhythmUI/HeelBar"
	)


	hit_text = get_tree().current_scene.get_node(
		"UI/RhythmUI/HitText"
	)


	combo_label = get_tree().current_scene.get_node(
		"UI/RhythmUI/ComboLabel"
	)


	points_label = get_tree().current_scene.get_node(
		"UI/RhythmUI/PointsLabel"
	)


	# Normal note color
	$Visual.color = Color.WHITE


	# Scale note from center
	pivot_offset = size / 2.0


	# Scale combo from center
	combo_label.pivot_offset = combo_label.size / 2.0


	update_combo_ui()



func _process(delta: float) -> void:

	if finished:
		return


	position.y += speed * delta


	# A
	if lane == 0 and Input.is_action_just_pressed("hit_left"):

		try_hit()


	# S
	elif lane == 1 and Input.is_action_just_pressed("hit_middle"):

		try_hit()


	# D
	elif lane == 2 and Input.is_action_just_pressed("hit_right"):

		try_hit()


	# Note passed hit area
	if position.y > hit_y + hit_range:

		miss_note()




func try_hit() -> void:

	if finished:
		return


	var distance: float = abs(position.y - hit_y)


	if distance <= hit_range:

		finished = true



		combo += 1


		# 10 points for every PERFECT
		total_points += 10


		# Your existing progress score
		heel_bar.value += 10


		update_combo_ui()

		animate_combo()




		show_hit_text("PERFECT!")


		print(
			"PERFECT! COMBO: ",
			combo,
			" POINTS: ",
			total_points
		)


		# Note turns black + pops
		await perfect_effect()


		queue_free()




func update_combo_ui() -> void:

	combo_label.text = "COMBO x" + str(combo)

	points_label.text = str(total_points) + " PTS"




func animate_combo() -> void:

	combo_label.pivot_offset = combo_label.size / 2.0


	# Start normal
	combo_label.scale = Vector2(1.0, 1.0)


	var tween = create_tween()


	# POP REALLY BIG
	tween.tween_property(
		combo_label,
		"scale",
		Vector2(1.3, 1.3),
		0.08
	)


	# Slowly come back down
	tween.tween_property(
		combo_label,
		"scale",
		Vector2(1.0, 1.0),
		0.45
	)


# =========================
# PERFECT NOTE EFFECT
# =========================

func perfect_effect() -> void:

	# Stop note at hit line
	position.y = hit_y


	# Turn note BLACK
	$Visual.color = Color.BLACK


	pivot_offset = size / 2.0

	scale = Vector2(1.0, 1.0)


	var tween = create_tween()


	# Pop note bigger
	tween.tween_property(
		self,
		"scale",
		Vector2(1.5, 1.5),
		0.08
	)


	# Slowly shrink
	tween.tween_property(
		self,
		"scale",
		Vector2(0.7, 0.7),
		0.10
	)


	# Fade away
	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		0.10
	)


	await tween.finished


# =========================
# MISS
# =========================

func miss_note() -> void:

	if finished:
		return


	finished = true


	# =========================
	# BREAK COMBO
	# =========================

	combo = 0

	update_combo_ui()


	show_hit_text("MISS!")


	print("MISS! COMBO RESET")


	queue_free()


# =========================
# PERFECT / MISS TEXT
# =========================

func show_hit_text(message: String) -> void:

	hit_text.text = message

	hit_text.visible = true


	await get_tree().create_timer(0.5).timeout


	if hit_text.text == message:

		hit_text.text = ""

		hit_text.visible = false
