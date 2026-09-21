extends Node

var note_scene = preload("res://levels/note.tscn")

@export var bpm: float = 117.45
@export var beats_per_note: float = 1.0

var stopped: bool = false
var next_beat: float = 0.0
var beat_length: float

@export var beat_offset: float = 0.07

@export var music: AudioStreamPlayer


func _ready() -> void:
	beat_length = 60.0 / bpm


func _process(_delta: float) -> void:
	if stopped:
		return

	if music == null:
		return

	if !music.playing:
		return

	var song_time = music.get_playback_position()

	# Don't spawn until the actual beat section starts.
	if song_time < beat_offset:
		return

	var beat_time = song_time - beat_offset
	var current_beat = floor(beat_time / beat_length)

	if current_beat >= next_beat:
		spawn_note()
		next_beat = current_beat + beats_per_note


func spawn_note() -> void:
	var rhythm_ui = get_tree().current_scene.get_node("UI/RhythmUI")

	var lane_left = rhythm_ui.find_child("LaneLeft", true, false)
	var lane_middle = rhythm_ui.find_child("LaneMiddle", true, false)
	var lane_right = rhythm_ui.find_child("LaneRight", true, false)
	var hit_line = rhythm_ui.find_child("HitLine", true, false)

	if lane_left == null:
		print("ERROR: LaneLeft not found")
		return

	if lane_middle == null:
		print("ERROR: LaneMiddle not found")
		return

	if lane_right == null:
		print("ERROR: LaneRight not found")
		return

	if hit_line == null:
		print("ERROR: HitLine not found")
		return

	var note = note_scene.instantiate()

	var lane_number: int = randi_range(0, 2)
	note.lane = lane_number

	var selected_lane: Control

	if lane_number == 0:
		selected_lane = lane_left
	elif lane_number == 1:
		selected_lane = lane_middle
	else:
		selected_lane = lane_right

	rhythm_ui.add_child(note)

	var lane_center: float = selected_lane.position.x + selected_lane.size.x / 2.0

	note.position.x = lane_center - note.size.x / 2.0 + 48.0
	note.position.y = selected_lane.position.y

	note.hit_y = hit_line.position.y - note.size.y / 2.0


func stop_spawning() -> void:
	stopped = true


func restart() -> void:
	stopped = false
	next_beat = 0.0
