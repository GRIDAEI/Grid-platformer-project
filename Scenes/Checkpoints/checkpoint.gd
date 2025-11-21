extends Area2D
var checkpoint_manager
# Called when the node enters the scene tree for the first time.

func _ready():
	checkpoint_manager = get_parent().get_parent().get_node("CheckpointManager")
	

func _on_body_entered(body):
	if body.is_in_group("Player"):
		checkpoint_manager.LastLocation = $RespawnPoint.global_position
