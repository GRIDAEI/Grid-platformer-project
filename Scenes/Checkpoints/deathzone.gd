extends Area2D

var player : Player
# Called when the node enters the scene tree for the first time.
func _ready():
	player = GameManager.player
	pass # Replace with function body.



	
func _on_body_entered(body):
	
	if body.is_in_group("Player"):
		killplayer()
		
func killplayer():
	if !player:
		player = GameManager.player
	player.global_position = CheckpointManager.LastLocation
	player.velocity = Vector2(0,0)
	player.air_direction = 0.0
	pass
