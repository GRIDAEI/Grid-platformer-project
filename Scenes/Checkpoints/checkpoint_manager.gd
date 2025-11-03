extends Node

var LastLocation
var player



# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("CharacterBody2D")
	LastLocation = player.global_position
	
