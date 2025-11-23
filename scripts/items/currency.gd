extends Area2D


func _ready() -> void:
	var collector = GameManager.player.currency_collector
	collector.currency_collected.connect(_on_being_collected)

# Po byciu zebranym przez gracza znika kolizja i sprite, ale odpala się timer,
# żeby pieniążek zdążył zagrać dźwięk zbierania (jeszcze nie dodany) przed byciem usuniętym
func _on_being_collected(area: Area2D) -> void:
	if area == self:
		$CollisionShape2D.call_deferred("set_disabled", true)
		$Sprite2D.visible = false
		$Sfx.play()


func _on_sfx_finished() -> void:
	queue_free()
