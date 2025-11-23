extends CharacterBody2D
class_name Player

#Siła skoku
@export var JUMP_VELOCITY : float = 400.0
@export var HIGH_JUMP_VELOCITY : float =400
@export var wall_jump_pushback : float = 500.0
@export var wall_slide_speed_reduction : float = 0.3
#Siła kontroli w powietrzu
@export var AIR_CONTROL : float = 3.0

var has_just_jumped : bool = false
var has_jumped : bool = false
# maksymalny czas przytrzymania spacji (w sekundach) by osiągnąć pełny skok
@export var MAX_JUMP_HOLD_TIME : float = 0.3
var current_jump_hold_time : float = 0.00

var long_jump_threshold = 0.1

#Prędkości poruszania się względem stanu
@export var walk_speed : float = 300.0
@export var sprint_speed : float = 500.0
@export var acceleration = 2048

#Aktualna prędkość
var current_speed : float = 0.0



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

#Zmienne helper
#Helper, bo nie wiem jak się to profesjonalniej nazywa to zmienne które obsługują dodatkowe wspomagacze dla gracza

#Helper np. jest to że jeszcze przez 30 klatek po zejściu z platformy można jeszcze skoczyć. By gracz nie czuł
#się oszukany.
var helper_duration : int = 10
var normal_jump_help_timer : int = 10
var helper_wall_jump_help_timer : int = 10

#Kontroler animacji gracza
@onready var anim_sprite = $AnimatedSprite2D

#Sprawdzacze od czego się odbil gracz
var was_on_floor : bool = false
var was_on_wall : bool = false




# wewnętrzne zmienne dla przytrzymania skoku
var prejump : bool = false

#To może będzie przydatne kiedyś
var last_dir : float = 0.0
var last_wall


@onready var currency_collector = $CurrencyCollector
func _ready() -> void:
	GameManager.player = self
	
func _physics_process(delta: float) -> void:
	if !GameManager.player:
		GameManager.player = self
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
			velocity.x = move_toward(velocity.x, direction * current_speed, acceleration*delta)
		else:
			velocity.x = move_toward(velocity.x, 0, acceleration*delta)
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
	if was_on_floor and !is_on_floor() and !has_just_jumped:
		normal_jump_help_timer = 8
	
	if was_on_wall and !is_on_wall() and !has_just_jumped:
		helper_wall_jump_help_timer = 8
	
	
	if is_on_floor():
		was_on_floor = true
		
	else:
		was_on_floor = false
	
	if is_on_wall():
		was_on_wall = true
	else:
		was_on_wall = false
	
	if has_just_jumped:
		has_just_jumped = false
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


#Aktualizacja animacji na podstawie Playerstate
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
	
	if velocity.x > 0:
		anim_sprite.flip_h = false
	elif velocity.x < 0:
		anim_sprite.flip_h = true
	
#ustawianie prędkość względem stanu
func updateSpeed():
	if player_state == PlayerState.WALKING:
		current_speed = walk_speed
	elif player_state == PlayerState.SPRINTING:
		current_speed = sprint_speed


#funkcja obśługująca skok
func jump(delta):
	
	if is_on_floor():
		air_direction = 0.0
		has_jumped = false
		
	if is_on_wall():
		if velocity.y < -50:
			velocity += get_gravity() * delta * Vector2(1.0, wall_slide_speed_reduction * 2.5)
		else:
			velocity += get_gravity() * delta * Vector2(1.0, wall_slide_speed_reduction)
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
		prejump = true
		current_jump_hold_time = 0.00
	if Input.is_action_just_released("spacja"):
		prejump = false
		has_jumped = false
	
	var holding_space = false
	
	#PRÓBA ZROBIENIA HOLD_SPACE JUMP
	#if Input.is_action_pressed("spacja") and has_jumped:
		#current_jump_hold_time += delta
		#holding_space = true
			#
		#if current_jump_hold_time < MAX_JUMP_HOLD_TIME and !is_on_wall():
			#velocity.y = lerp(-JUMP_VELOCITY, -HIGH_JUMP_VELOCITY, current_jump_hold_time/MAX_JUMP_HOLD_TIME)
		#else:
			#has_jumped = false
			
			
			
	if prejump:
		
		if is_on_floor() or is_helper_active(normal_jump_help_timer):
			prejump = false
			has_just_jumped = true
			has_jumped = true
			if !holding_space:
				velocity.y = -HIGH_JUMP_VELOCITY
			# zapamiętujemy kierunek powietrzny (jeśli gracz trzyma kierunek)
			if abs(direction) > 0.5 :
				air_direction = sign(direction)
			else:
				air_direction = 0.0
			return

		# 2) Wall-jump (gdy przy ścianie i nie na ziemi)
		if (is_on_wall() or helper_wall_jump_help_timer) and not is_on_floor() :
			has_just_jumped = true
			prejump = false
			var wall_side  = get_wall_normal()
			air_direction = wall_side.x
			velocity.x = wall_side.x * wall_jump_pushback
			velocity.y = -JUMP_VELOCITY
			last_wall = wall_side
			return
