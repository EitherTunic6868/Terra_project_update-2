extends CharacterBody2D

@onready var immunity_timer: Timer = $"Immunity timer"
@onready var death_time: Timer = $"Death time"
var immunity = true # I declared immunity from the start to fix a bug that would make the player take damage when the scene started
signal immunity_stopped

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const SPEED = 100.0

signal update_player_health()
const MAX_HEALTH = 100
var health = 100

const JUMP_VELOCITY = -300
const MAX_JUMPS = 1
var jump_count = 0

const MAX_DASH = 1
const DASH_SPEED = 900.0
@onready var dash_time: Timer = $"Dash time"
var dashing = false
var dash_count = 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var coyote_timer: Timer = $"Coyote timer"
var was_on_floor =  is_on_floor()

func _physics_process(delta: float) -> void:
	
	emit_signal("update_player_health", health)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("Move left", "Move right")
	
	# Flips sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		elif direction != 0 and dashing == true:
			animated_sprite.play("Jump")
		else:
			animated_sprite.play("Run")
	else:
		animated_sprite.play("Jump")
	
	# Starts a dash
	if Input.is_action_just_pressed("Dash") and dash_count < MAX_DASH:
		dashing = true
		dash_count += 1
		dash_time.start()
	
	# Apply movement
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	
	# Checks if Coyote time should be applied
	if was_on_floor != is_on_floor():
		coyote_timer.start()

	# Handle jump/double jump.
	if Input.is_action_just_pressed("Jump") and ((is_on_floor() or !coyote_timer.is_stopped()) or jump_count < MAX_JUMPS):
		velocity.y = JUMP_VELOCITY
		jump_count += 1
	
	# Resets double jump and dash
	if is_on_floor():
		jump_count = 0
		dash_count = 0
	elif !is_on_floor() and !coyote_timer.is_stopped():
		jump_count = 0
		dash_count = 0
	

# Stops a dash
func _on_dash_time_timeout() -> void:
	dashing = false

# deals damage
func _on_game_manager_damage_player(damage) -> void:
	if immunity == false:
		health -= damage
		
	immunity = true
	immunity_timer.start()
	
	if health <= 0:
		health = 0
		death()
	emit_signal("update_player_health", health)


func _on_green_berry_heal(health_added) -> void:
	if health + health_added > MAX_HEALTH:
		health = MAX_HEALTH
	else:
		health += health_added
	print(health)


#gives the player immunity from damage for 2 seconds to prevents combo hits
func _on_immunity_timer_timeout() -> void:
	immunity = false
	emit_signal("immunity_stopped") 

# insta kills player
func _on_game_manager_kill_player() -> void:
	death()

# makes the player fall through the map when they die and restarts the scene
func death():

	Engine.time_scale = 0.5
	collision_shape.queue_free()
	death_time.start()
	
	await death_time.timeout
	
	get_tree().reload_current_scene()
	Engine.time_scale = 1
