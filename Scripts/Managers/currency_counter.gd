extends Control

var currency: int = 0

func _ready() -> void:
	var collector = get_node("/root/TestLevel/Player/CurrencyCollector")
	collector.currency_collected.connect(_on_currency_collected)


func _on_currency_collected(_area: Area2D):
	currency += 1
	$Counter.text = str(currency)
