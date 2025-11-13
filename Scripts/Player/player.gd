extends CharacterBody2D
class_name Player

#Siła skoku
@export var JUMP_VELOCITY : float = 400.0
@export var wall_jump_pushback : float = 500.0

@export var wall_slide_speed_reduction : float = 0.3


#Zmienne forów
#Fory, bo nie wiem jak się to profesjonalniej nazywa to zmienne które obsługują dodatkowe wspomagacze dla gracza

#Forem np. jest to że jeszcze przez 30 klatek po zejściu z platformy można jeszcze skoczyć. By gracz nie czuł
#się oszukany.
var helper_duration : int = 10
var normal_jump_help_timer : int = 10
var helper_wall_jump_help_timer : int = 10

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


var was_on_floor : bool = false
var was_on_wall : bool = false
var was_wall_jump : bool = false
var jump_boost_active : bool = false

var has_jumped : bool = false

var last_dir : float = 0.0


func _physics_process(delta: float) -> void:
	
	#Pobierz input
	input_dir = Input.get_axis("left", "right")
	
	updatePlayerState()
	#Kierunek to wygładzony kierunek zmierzający do input_dir
	direction = lerp(direction, input_dir, delta*10.0)
	
	
	# Handle jump.
	update_helpers()
	decrement_helpers()
	
	jump(delta)
	
	if is_on_floor():
		if abs(direction) > 0.01:
			velocity.x = direction * current_speed #Poruszaj jeżeli jest wciśniety kierunek
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed * delta * 10) # delikatne hamowanie na ziemi
	else:
		#kierunek przed skokiem
		var target_dir := air_direction
		if target_dir == input_dir * -1:
			air_direction = 0.0
		if abs(input_dir) > 0.01:
			target_dir = input_dir
		
		#Powolne skręcanie w stronę inputu
		velocity.x = lerp(velocity.x, target_dir * current_speed, clamp(AIR_CONTROL * delta, 0, 1))
	move_and_slide()


func decrement_helpers():
	if normal_jump_help_timer > 0:
		normal_jump_help_timer -= 1
	if helper_wall_jump_help_timer>0:
		helper_wall_jump_help_timer -= 1

func is_helper_active(helper):
	if helper > 0:
		return true
	else:
		return false


func update_helpers():
	if was_on_floor and !is_on_floor() and !has_jumped:
		normal_jump_help_timer = 8
	
	if was_on_wall and !is_on_wall() and !has_jumped:
		helper_wall_jump_help_timer = 8
	
	
	if is_on_floor():
		was_on_floor = true
	else:
		was_on_floor = false
	
	if is_on_wall():
		was_on_wall = true
	else:
		was_on_wall = false
	
	if has_jumped:
		has_jumped = false
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
	
	if !was_wall_jump:
		anim_sprite.flip_h = direction < 0
#ustawianie prędkość względem stanu
func updateSpeed():
	if player_state == PlayerState.WALKING:
		current_speed = walk_speed
	elif player_state == PlayerState.SPRINTING:
		current_speed = sprint_speed


#funkcja obsługująca skok
func jump(delta):
	if is_on_floor():
		was_wall_jump = false
	if is_on_wall():
		
		if velocity.y < -150:
			velocity += get_gravity() * delta * Vector2(1.0, wall_slide_speed_reduction * 2.5)
		else:
			velocity += get_gravity() * delta * Vector2(1.0, wall_slide_speed_reduction)
		
		#Wybieranie kierunku gracza
		if last_dir > 0:
			anim_sprite.flip_h = false
		elif last_dir <0:
			anim_sprite.flip_h = true
	else:
		# w powietrzu normalna grawitacja
		velocity += get_gravity() * delta
	
	#Determinowanie kierunku który ma obrać gracz po skoku od ściany
	
	#jeżeli nie na ścianie
	if !is_on_wall():
		#Sprawdzamy czy jest input, jeżeli tak to on ma priorytet kierunku
		if abs(input_dir):
			last_dir = direction
		else:
			#Gdy inputu nie mamy wybieramy kierunek na podstawie poziomego velocity
			last_dir = velocity.x
	
	# --- Skok (input) ---
	if Input.is_action_just_pressed("spacja"):
		# 1) Skok z ziemi
		
		if is_on_floor() or is_helper_active(normal_jump_help_timer):
			has_jumped = true
			velocity.y = -JUMP_VELOCITY
			# zapamiętujemy kierunek powietrzny (jeśli gracz trzyma kierunek)
			if abs(direction) > 0.5 or abs(velocity.x) > 190:
				air_direction = sign(direction)
			else:
				air_direction = 0.0
			return

		# 2) Wall-jump (gdy przy ścianie i nie na ziemi)
		if (is_on_wall() or helper_wall_jump_help_timer) and not is_on_floor() :
			has_jumped = true
			
			var wall_side := 0.0
			
			#Tutaj ustalamy w kierunku gracz zostanie odbity. Robimy tu to w razie gdyby last_dir miał niewypał.
			# preferuj kierunek od gracza (input_dir), jeżeli istnieje
			if abs(input_dir) > 0.01:
				#bierzemy znak
				wall_side = sign(direction)
			else:
				# brak wejścia — użyj flipu sprite'a jako przybliżenia strony ściany
				wall_side = -1.0 if anim_sprite.flip_h else 1.0
				
			#kierunek boosta w odwrotną stronę od ściany
			air_direction = -wall_side
			
			#Dodanie prędkości
			velocity.x = air_direction * current_speed
			velocity.y = -JUMP_VELOCITY
			
			#Tak, skoczono
			was_wall_jump = true
			return
