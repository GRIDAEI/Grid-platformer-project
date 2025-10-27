extends Node2D

# Tutaj modyfikować kod
var options = [
	{"text": "Continue", "doer":cont},
	{"text": "Settings", "doer":sett},
	{"text": "Quit", "doer":quit},
]

var index = 0 # tl;dr tl;dr
var change = false # Użytkownik nie może dawać menu inputów podczas tego
var update = false # Gdy animacja się skończy, ta funkcja pozwoli na wykonanie skryptu W TEJ SAMEJ KRATCE co reset animacji

func _ready() -> void:
	update_notes()
	pass

func _process(delta: float) -> void:
	# Spinning shapes
	rot($BgFlash, 0.1*delta, PI/24*11, -PI/12)
	rot($BgFlash2, 0.1*delta, PI/24*11, -PI/12)
	
	#Inputs
	if(Input.is_action_just_pressed("ui_accept") and not change):
		$AnimationPlayer.play("Menu_This")
		change = true

	if(Input.is_action_just_pressed("ui_up") and not change):
		$AnimationPlayer.play("Menu_Prev")
		change = true
		index-=1
	if(Input.is_action_just_pressed("ui_down") and not change):
		$AnimationPlayer.play("Menu_Next")
		change = true
		index+=1
	
	# index modulo
	if(index >= options.size()): index -= options.size()
	if(index < 0): index += options.size()
	
	# Post Animation Update
	if(update):
		update_notes()
		update = false
		change = false

# <amount> to ile się obraca; <reset> to taki check, który teleportuje o <reset_amount> żeby dawać iluzję pełnego kształtu
func rot(shape: Polygon2D, amount, reset, reset_amount):
	shape.rotate(amount)
	if(-shape.rotation < reset):
		shape.rotate(reset_amount)

# Refreshuje napisy na menu po animacji
func update_notes():
	#print(fposmod((index-1),options.size()))
	$Note0/Text.text = options[fposmod((index-1),options.size())]["text"]
	$Note/Text.text = options[index]["text"]
	$Note2/Text.text = options[(index+1)%options.size()]["text"]
	$Note3/Text.text = options[(index+2)%options.size()]["text"]
	$Note4/Text.text = options[(index+3)%options.size()]["text"]
	
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name != "RESET"):
		update = true
		#print("finished")
		$AnimationPlayer.play("RESET")
	if(anim_name == "Menu_This"):
		options[index]["doer"].call()
	pass # Replace with function body.


# Tutaj modifikować kod 
func cont():
	print("Continue WOO")
func sett():
	print("Settings WOO")
func quit():
	print("Quitter WOO")
