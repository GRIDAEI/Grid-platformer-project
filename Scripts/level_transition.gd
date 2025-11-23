extends Node2D


func _on_level_transition_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameManager.go_to_next_level()
