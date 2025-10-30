extends CharacterBody2D
class_name Player

#Siła skoku
@export var JUMP_VELOCITY : float = 400.0
@export var wall_jump_pushback : float = 500.0

@export var wall_slide_speed_reduction : float = 0.3


#Stany gracza
enum PlayerState {
	IDLE,
	WALKING,
	SPRINTING,
	AIR,
	WALLSLIDE
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

#Kontroler animacji gracza
@onready var anim_sprite = $AnimatedSprite2D

var was_wall_jump : bool = false

func _physics_process(delta: float) -> void:
	
	#Pobierz input
	input_dir = Input.get_axis("left", "right")
	
	updatePlayerState()
	#Kierunek to wygładzony kierunek zmierzający do input_dir
	direction = lerp(direction, input_dir, delta*10.0)
	
	
	# Handle jump.
	
	
	jump(delta)
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
		if is_on_wall():
			player_state = PlayerState.WALLSLIDE
		else:
			player_state = PlayerState.AIR
	else:
		if not moving:
			player_state = PlayerState.IDLE
		elif Input.is_action_pressed("sprint"):
			player_state = PlayerState.SPRINTING
		else:
			player_state = PlayerState.WALKING
	updateAnimation()
	updateSpeed()


func updateAnimation():
	var anim_to_play = ""
	match player_state:
		PlayerState.IDLE:
			anim_to_play = "default"
		PlayerState.WALKING:
			anim_to_play = "walk"
		PlayerState.SPRINTING:
			anim_to_play = "run"
		PlayerState.AIR:
			if velocity.y <0:
				anim_to_play = "jump_start"
			else:
				anim_to_play = "jump_end"
		PlayerState.WALLSLIDE:
			anim_to_play = "wall_slide"
	if anim_to_play != anim_sprite.animation:
		anim_sprite.play(anim_to_play)
	#zmień kierunek gracza
	anim_sprite.flip_h = direction < 0

#ustawianie prędkość względem stanu
func updateSpeed():
	if player_state == PlayerState.WALKING:
		current_speed = walk_speed
	elif player_state == PlayerState.SPRINTING:
		current_speed = sprint_speed


#funkcja obśługująca skok
func jump(delta):
	#Dodaj prędkość w górę
	if not is_on_floor():
		if is_on_wall():
			velocity += get_gravity() * delta * Vector2(1.0,wall_slide_speed_reduction)
		else:
			velocity += get_gravity() * delta
	else:
		was_wall_jump = false
	if Input.is_action_just_pressed("spacja"):
		if is_on_floor():
			velocity.y = -JUMP_VELOCITY
		
		if is_on_wall() and !is_on_floor():
			
			var wall_side := 0.0
			if abs(direction) > 0.01:
				wall_side = sign(direction)
			elif abs(velocity.x) > 0.01:
				wall_side = sign(velocity.x)
			else:
				wall_side = -1.0 if anim_sprite.flip_h else 1.0

			air_direction = -wall_side

			velocity.x = air_direction * (current_speed)
			velocity.y = -JUMP_VELOCITY
			was_wall_jump = true
		else:
			# jeśli gracz dawał kierunek -> użyj go, w przeciwnym razie użyj aktualnej prędkości poziomej (sign)
			if abs(direction) > 0.1:
				#Zapamiętaujemy kierunek przed skokiem
				air_direction = sign(direction)
			else:
				if !was_wall_jump:
					air_direction = sign(velocity.x) if abs(velocity.x) > 0.1 else 0.0
					
	
		
