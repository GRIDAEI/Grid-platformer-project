extends Node2D



func _process(delta: float) -> void:
	rot($BgFlash, 0.1*delta, PI/24*11, -PI/12)
	rot($BgFlash2, 0.1*delta, PI/24*11, -PI/12)


func rot(shape: Polygon2D, amount, reset, reset_amount):
	shape.rotate(amount)
	if(-shape.rotation < reset):
		shape.rotate(reset_amount)
