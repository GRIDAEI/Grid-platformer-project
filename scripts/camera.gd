extends Camera2D

@export var BoundingPoint1: Vector2 = Vector2(0,0)
@export var BoundingPoint2: Vector2 = Vector2(0,0)
@export var speed: float = 1.0
var vel = Vector2.ZERO

func _ready() -> void:
	var temp = BoundingPoint1.min(BoundingPoint2)
	BoundingPoint2 = BoundingPoint1.max(BoundingPoint2)
	BoundingPoint1 = temp
	
func _process(delta: float) -> void:
	vel = Vector2.ZERO
	if GameManager.player:
		vel = GameManager.player.position - position
	
	position += vel * delta * speed
	if(position.min(BoundingPoint1) != BoundingPoint1):
		position = position.max(BoundingPoint1)
	if(position.max(BoundingPoint1) != BoundingPoint2):
		position = position.min(BoundingPoint2)
	
	
	pass
