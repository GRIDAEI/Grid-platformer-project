extends Area2D

signal currency_collected(area)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("currency"):
		emit_signal("currency_collected", area)
