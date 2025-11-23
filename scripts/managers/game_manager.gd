extends Node
class_name game_manager
# This script has objects and functions that are related to the core of the game
# or otherwise commonly used objects like Player

# It can be accessed globally by typing GameManager
# For example if you want to check player's health from an isolated scene:
# var hp = GameManager.player.get_health()


signal game_paused
signal game_unpaused

var player: Player
var is_paused: bool

var currency_counter
var game_holder
var checkpoint_manager


func _ready() -> void:
	player = find_child_of_type(get_tree().current_scene, Player)
	
func pause() -> void:
	is_paused = true
	game_paused.emit()

func unpause() -> void:
	is_paused = false
	game_unpaused.emit()
	
func find_child_of_type(parent: Node, type) -> Node:
	for child in parent.get_children():
		if is_instance_of(child, type):
			return child
		var found = find_child_of_type(child, type)
		if found:
			return found

	return null

func go_to_next_level():
	game_holder.advance_level()
