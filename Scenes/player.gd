extends CharacterBody2D

#Siła skoku
const JUMP_VELOCITY = -400.0





#Stany gracza
enum PlayerState {
	IDLE,
	WALKING,
	SPRINTING,
	AIR
}
#Aktualny stan gracza
var player_state : PlayerState = PlayerState.IDLE

#Wejściowe dane
var input_dir : float = 0.0
#Kierunek przesuwania gracza
var direction= 0.0
#Kierunek przesuwania gracza w powietrzy
var air_direction := 0.0 

#Czy gracz się rusza?
var moving : bool = false

#Prędkości poruszania się względem stanu
@export var walk_speed : float = 300.0
@export var sprint_speed : float = 500.0

#Siła kontroli w powietrzu
@export var AIR_CONTROL : float = 3.0

#Aktualna prędkość
var current_speed : float = 0.0


func _physics_process(delta: float) -> void:
	updatePlayerState()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Pobierz input
	input_dir = Input.get_axis("left", "right")
	
	#Kierunek to wygładzony kierunek zmierzający do input_dir
	direction = lerp(direction, input_dir, delta*10.0)
	
	# Handle jump.
	if Input.is_action_just_pressed("spacja") and is_on_floor():
		#Dodaj prędkość w górę
		velocity.y = JUMP_VELOCITY
		# jeśli gracz dawał kierunek -> użyj go, w przeciwnym razie użyj aktualnej prędkości poziomej (sign)
		if abs(direction) > 0.1:
			#Zapamiętaujemy kierunek przed skokiem
			air_direction = sign(direction)
		else:
			air_direction = sign(velocity.x) if abs(velocity.x) > 0.1 else 0.0
	

	if is_on_floor():
		if abs(direction) > 0.01:
			velocity.x = direction * current_speed #Poruszaj jeżeli jest wciśniety kierunek
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed * delta * 10) # delikatne hamowanie na ziemi
	else:
		#kierunek przed skokiem
		var target_dir := air_direction
		if abs(input_dir) > 0.01:
			target_dir = input_dir
		
		#Powolne skręcanie w stronę inputu
		velocity.x = lerp(velocity.x, target_dir * current_speed, clamp(AIR_CONTROL * delta, 0, 1))
		
	
	move_and_slide()

#Ustawianie state playera
func updatePlayerState() -> void:
	moving = (input_dir != 0.0)
	if not is_on_floor():
		
		player_state = PlayerState.AIR
	else:
		if not moving:
			player_state = PlayerState.IDLE
		elif Input.is_action_pressed("sprint"):
			player_state = PlayerState.SPRINTING
		else:
			player_state = PlayerState.WALKING
	updateSpeed()

#ustawianie prędkość względem stanu
func updateSpeed():
	if player_state == PlayerState.WALKING:
		current_speed = walk_speed
	elif player_state == PlayerState.SPRINTING:
		current_speed = sprint_speed
