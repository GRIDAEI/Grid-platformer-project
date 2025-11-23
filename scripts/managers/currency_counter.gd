extends Control

var currency: int = 0

func _ready() -> void:
	GameManager.currency_counter = self
	connect_collector()

func connect_collector():
	var collector = GameManager.player.currency_collector
	collector.currency_collected.connect(_on_currency_collected)

func _on_currency_collected(_area: Area2D):
	currency += 1
	$Counter.text = "x  "+ str(currency)
