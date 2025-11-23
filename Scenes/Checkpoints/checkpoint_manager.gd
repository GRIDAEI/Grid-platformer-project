extends Node

var LastLocation
var player



# Called when the node enters the scene tree for the first time.
func _ready():
	player = GameManager.player
	if player:
		CheckpointManager.LastLocation = player.global_position
