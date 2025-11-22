extends Area2D

var checkpoint_manager
var player : Player
# Called when the node enters the scene tree for the first time.
func _ready():
	checkpoint_manager = get_parent().get_node("CheckpointManager")
	player = GameManager.player
	pass # Replace with function body.



	
func _on_body_entered(body):
	
	if body.is_in_group("Player"):
		killplayer()
		
func killplayer():
	player.position = CheckpointManager.LastLocation
	player.velocity = Vector2(0,0)
	player.air_direction = 0.0
	pass
