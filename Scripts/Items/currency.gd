extends Area2D


func _ready() -> void:
	var collector = get_node("/root/TestLevel/Player/CurrencyCollector")
	collector.currency_collected.connect(_on_being_collected)

# Po byciu zebranym przez gracza znika kolizja i sprite, ale odpala się timer,
# żeby pieniążek zdążył zagrać dźwięk zbierania (jeszcze nie dodany) przed byciem usuniętym
func _on_being_collected(area: Area2D) -> void:
	if area == self:
		$CollisionShape2D.call_deferred("set_disabled", true)
		$Sprite2D.visible = false
		$QueueFreeTimer.start()
		$Sfx.play()


func _on_queue_free_timer_timeout() -> void:
	queue_free()
