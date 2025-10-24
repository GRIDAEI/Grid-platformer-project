extends CharacterBody2D

const JUMP_VELOCITY = -400.0

var direction= 0.0
var air_direction := 0.0 

var moving : bool = false

enum PlayerState {
	IDLE,
	WALKING,
	SPRINTING,
	AIR
}
var player_state : PlayerState = PlayerState.IDLE
var input_dir : float = 0.0

@export var walk_speed : float = 300.0
@export var sprint_speed : float = 500.0

@export var AIR_CONTROL : float = 3.0

var current_speed : float = 0.0
func _physics_process(delta: float) -> void:
	updatePlayerState()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_axis("left", "right")
	direction = lerp(direction, input_dir, delta*10.0)
	
	# Handle jump.
	if Input.is_action_just_pressed("spacja") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# jeśli gracz dawał kierunek -> użyj go, w przeciwnym razie użyj aktualnej prędkości poziomej (sign)
		if abs(direction) > 0.1:
			air_direction = sign(direction)
		else:
			air_direction = sign(velocity.x) if abs(velocity.x) > 0.1 else 0.0
		
	if is_on_floor():
		if abs(direction) > 0.01:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed * delta * 10) # delikatne hamowanie na ziemi
	else:
		if AIR_CONTROL <= 0.0:
			velocity.x = air_direction * current_speed
		else:
			var target_dir := air_direction
			if abs(input_dir) > 0.01:
				target_dir = input_dir
			velocity.x = lerp(velocity.x, target_dir * current_speed, clamp(AIR_CONTROL * delta, 0, 1))
		
	
	move_and_slide()


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

func updateSpeed():
	if player_state == PlayerState.WALKING:
		current_speed = walk_speed
	elif player_state == PlayerState.SPRINTING:
		current_speed = sprint_speed
