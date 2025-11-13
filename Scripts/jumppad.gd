extends Node2D

@export var strength : int = -600

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("jumppad")
	body.velocity.y = strength
