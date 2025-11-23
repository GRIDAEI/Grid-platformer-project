extends Node


@onready var current_scene_holder = $CurrentScene
var current_scene

var levels = [
	"res://Scenes/World.tscn",
	"res://Scenes/levels/level_1.tscn",
	"res://Scenes/levels/level_2.tscn",
	"res://Scenes/levels/level_3.tscn"
	
]

var level_cursor = 0

func _ready() -> void:
	GameManager.game_holder = self
	current_scene = current_scene_holder.get_child(0)
	advance_level()
func advance_level():
	transition_to_level(levels[level_cursor])
	if level_cursor < levels.size()-1:
		level_cursor += 1

func transition_to_level(level : String, delete : bool = true, keep_running : bool = false):
	if level != null:
		if delete:
			current_scene.queue_free()
		elif keep_running:
			current_scene.visible = false
		else:
			current_scene_holder.remove_child(current_scene)
	
	var new = load(level).instantiate()
	current_scene_holder.add_child(new)
	current_scene = new
	CheckpointManager.LastLocation =  current_scene.get_node("Player").global_position
