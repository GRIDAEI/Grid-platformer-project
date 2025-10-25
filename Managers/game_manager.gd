extends Node

# This script has objects and functions that are related to the core of the game
# or otherwise commonly used objects like Player

# It can be accessed globally by typing GameManager
# For example if you want to check player's health from an isolated scene:
# var hp = GameManager.player.get_health()

signal game_paused
signal game_unpaused

var player: Player
var is_paused: bool

func pause() -> void:
	is_paused = true
	game_paused.emit()

func unpause() -> void:
	is_paused = false
	game_unpaused.emit()
