extends Node3D



@export var battle_time: float = 30.0
@export var sneaker_delay: float = 1.2




@onready var heel_bar: ProgressBar = $UI/RhythmUI/HeelBar
@onready var sneaker_bar: ProgressBar = $UI/RhythmUI/SneakerBar

@onready var heel_label: Label = $UI/RhythmUI/HeelLabel
@onready var sneaker_label: Label = $UI/RhythmUI/SneakerLabel

@onready var hit_text: Label = $UI/RhythmUI/HitText
@onready var combo_label: Label = $UI/RhythmUI/ComboLabel
@onready var points_label: Label = $UI/RhythmUI/PointsLabel

@onready var win_text: Label = $UI/RhythmUI/WinText

@onready var left_key: Control = $UI/RhythmUI/Lines/LeftKey
@onready var middle_key: Control = $UI/RhythmUI/Lines/MiddleKey
@onready var right_key: Control = $UI/RhythmUI/Lines/RightKey




@onready var note_spawner = $UI/RhythmUI/NoteSpawner
@onready var battle_music: AudioStreamPlayer = $BattleMusic
@onready var end_screen: Control = $EndScreen

@onready var heel_animation: AnimationPlayer = $Heel/Heels/AnimationPlayer
@onready var sneaker_animation: AnimationPlayer = $Sneaker/Sneakers/AnimationPlayer




var battle_running: bool = false
var battle_finished: bool = false

var sneaker_timer: float = 0.0
var sneaker_can_score: bool = false

var normal_key_scale := Vector2(1.0, 1.0)
var pressed_key_scale := Vector2(1.6, 1.6)




func _ready() -> void:

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)




	var note_script = load("res://scripts/note.gd")

	if note_script != null:
		note_script.combo = 0
		note_script.total_points = 0




	heel_bar.value = 0
	sneaker_bar.value = 0




	hit_text.text = ""
	hit_text.visible = false

	combo_label.text = "COMBO x0"
	points_label.text = "0 PTS"

	combo_label.visible = true
	points_label.visible = true

	win_text.text = ""
	win_text.visible = false

	end_screen.visible = false



	$Heel.visible = true
	$Sneaker.visible = true




	left_key.pivot_offset = left_key.size / 2.0
	middle_key.pivot_offset = middle_key.size / 2.0
	right_key.pivot_offset = right_key.size / 2.0

	left_key.scale = normal_key_scale
	middle_key.scale = normal_key_scale
	right_key.scale = normal_key_scale




	battle_running = false
	battle_finished = false

	sneaker_can_score = false
	sneaker_timer = 0.0

	battle_music.stop()



	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	await get_tree().create_timer(1.0).timeout



	battle_running = true
	battle_music.play()



	if heel_animation.has_animation("dance"):
		heel_animation.play("dance")

	if sneaker_animation.has_animation("sneaker_dance"):
		sneaker_animation.play("sneaker_dance")



	start_sneaker_after_note_offset()





	start_battle_timer()




func start_sneaker_after_note_offset() -> void:

	sneaker_can_score = false

	# Reads the Level 1 NoteSpawner beat_offset.
	# Your Level 1 value is 7.712.
	await get_tree().create_timer(note_spawner.beat_offset).timeout

	if battle_finished:
		return

	sneaker_timer = 0.0
	sneaker_can_score = true


# =========================
# PROCESS
# =========================

func _process(delta: float) -> void:

	if !battle_running:
		return

	if battle_finished:
		return

	# Sneaker cannot score before the notes begin.
	if !sneaker_can_score:
		return

	sneaker_timer += delta

	if sneaker_timer >= sneaker_delay:
		sneaker_timer = 0.0
		sneaker_move()



func _input(event: InputEvent) -> void:

	if !battle_running:
		return

	if battle_finished:
		return

	if event.is_action_pressed("hit_left"):
		animate_key_press(left_key)

	elif event.is_action_pressed("hit_middle"):
		animate_key_press(middle_key)

	elif event.is_action_pressed("hit_right"):
		animate_key_press(right_key)




func animate_key_press(key: Control) -> void:

	key.pivot_offset = key.size / 2.0

	var tween = create_tween()

	tween.tween_property(
		key,
		"scale",
		pressed_key_scale,
		0.05
	)

	tween.tween_property(
		key,
		"scale",
		normal_key_scale,
		0.10
	)


func sneaker_move() -> void:

	if battle_finished:
		return

	if !sneaker_can_score:
		return

	# 75% chance Sneaker gets 5 points.
	if randf() <= 0.75:
		sneaker_bar.value += 5




func start_battle_timer() -> void:

	await get_tree().create_timer(battle_time).timeout

	if !battle_finished:
		end_battle()




func end_battle() -> void:

	if battle_finished:
		return

	battle_finished = true
	battle_running = false
	sneaker_can_score = false




	note_spawner.stop_spawning()

	get_tree().call_group(
		"rhythm_notes",
		"queue_free"
	)




	battle_music.stop()



	heel_bar.visible = false
	sneaker_bar.visible = false

	heel_label.visible = false
	sneaker_label.visible = false

	hit_text.visible = false

	combo_label.visible = false
	points_label.visible = false

	$UI/RhythmUI/Lines.visible = false



	if heel_bar.value > sneaker_bar.value:

		win_text.text = "HEEL WINS!"
		win_text.visible = true

		print("HEEL WINS!")

		# Stop Sneaker dance.
		sneaker_animation.stop()

		# BONK Sneaker.
		await bonk_character($Sneaker)




	elif sneaker_bar.value > heel_bar.value:

		win_text.text = "SNEAKER WINS!"
		win_text.visible = true

		print("SNEAKER WINS!")

		# Stop Heel dance.
		heel_animation.stop()

		# BONK Heel.
		await bonk_character($Heel)




	else:

		win_text.text = "DRAW!"
		win_text.visible = true

		print("DRAW!")

		await get_tree().create_timer(1.5).timeout




	win_text.visible = false

	await get_tree().create_timer(0.3).timeout


	

	end_screen.visible = true




func bonk_character(character: Node3D) -> void:

	var start_position: Vector3 = character.position
	var start_rotation: Vector3 = character.rotation_degrees

	var tween = create_tween()


	tween.tween_property(
		character,
		"position:y",
		start_position.y + 1.5,
		0.15
	)



	tween.parallel().tween_property(
		character,
		"rotation_degrees:z",
		start_rotation.z + 90.0,
		0.45
	)


	tween.tween_property(
		character,
		"position:y",
		start_position.y - 1.5,
		0.35
	)

	await tween.finished




	character.visible = false

	await get_tree().create_timer(0.5).timeout




func _on_try_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_next_level_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://levels/rhythm_battle_2.tscn"
	)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://levels/start_menu.tscn"
	)
