extends CharacterBody2D

class_name PlatformerController2D

signal jumped(is_ground_jump: bool)
signal hit_ground()


# Set these to the name of your action (in the Input Map)
## Name of input action to move left.
@export var input_left : String = "move_left"
## Name of input action to move right.
@export var input_right : String = "move_right"
## Name of input action to jump.
@export var input_jump : String = "jump"


const DEFAULT_MAX_JUMP_HEIGHT = 300
const DEFAULT_MIN_JUMP_HEIGHT = 60
const DEFAULT_DOUBLE_JUMP_HEIGHT = 100
const DEFAULT_JUMP_DURATION = 0.4

var _max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT
## The max jump height in pixels (holding jump).
@export var max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT: 
	get:
		return _max_jump_height
	set(value):
		_max_jump_height = value
	
		default_gravity = calculate_gravity(_max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(_max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)
			

var _min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT
## The minimum jump height (tapping jump).
@export var min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT: 
	get:
		return _min_jump_height
	set(value):
		_min_jump_height = value
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)



var _double_jump_height: float = DEFAULT_DOUBLE_JUMP_HEIGHT
## The height of your jump in the air.
@export var double_jump_height: float = DEFAULT_DOUBLE_JUMP_HEIGHT:
	get:
		return _double_jump_height
	set(value):
		_double_jump_height = value
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		

var _jump_duration: float = DEFAULT_JUMP_DURATION
## How long it takes to get to the peak of the jump in seconds.
@export var jump_duration: float = DEFAULT_JUMP_DURATION:
	get:
		return _jump_duration
	set(value):
		_jump_duration = value
	
		default_gravity = calculate_gravity(max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
		double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)
		
## Multiplies the gravity by this while falling.
@export var falling_gravity_multiplier = 1.5
## Amount of jumps allowed before needing to touch the ground again. Set to 2 for double jump.
@export var max_jump_amount = 1
@export var max_acceleration = 10000
@export var friction = 20
@export var can_hold_jump : bool = false
## You can still jump this many seconds after falling off a ledge.
@export var coyote_time : float = 0.1
## Pressing jump this many seconds before hitting the ground will still make you jump.
## Only neccessary when can_hold_jump is unchecked.
@export var jump_buffer : float = 0.1


# These will be calcualted automatically
# Gravity will be positive if it's going down, and negative if it's going up
var default_gravity : float
var jump_velocity : float
var double_jump_velocity : float
# Multiplies the gravity by this when we release jump
var release_gravity_multiplier : float


var jumps_left : int
var holding_jump := false

enum JumpType {NONE, GROUND, AIR}
## The type of jump the player is performing. Is JumpType.NONE if they player is on the ground.
var current_jump_type: JumpType = JumpType.NONE

# Used to detect if player just hit the ground
var _was_on_ground: bool

var acc = Vector2()

# coyote_time and jump_buffer must be above zero to work. Otherwise, godot will throw an error.
@onready var is_coyote_time_enabled = coyote_time > 0
@onready var is_jump_buffer_enabled = jump_buffer > 0
@onready var coyote_timer = Timer.new()
@onready var jump_buffer_timer = Timer.new()



##
# Added variables
#

var waterAmount : float = 50

var iframe : bool = false

#droplet
@export var droplet : PackedScene

#dash 
@export var dashDirection := Vector2(0,0)
@export var dashSpeed : float = 0
@export var inDash : bool = false
var can_dash : bool = true
var DashWaterDrop : Node2D

#apex of jump (need to be untyped)
var apex = null


#####################################

func _init():
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(jump_velocity, min_jump_height, default_gravity)


func _ready():
	
	$ShrimpGraphic/ShrimpAnim.play("Forward")
	
	if is_coyote_time_enabled:
		add_child(coyote_timer)
		coyote_timer.wait_time = coyote_time
		coyote_timer.one_shot = true
	
	if is_jump_buffer_enabled:
		add_child(jump_buffer_timer)
		jump_buffer_timer.wait_time = jump_buffer
		jump_buffer_timer.one_shot = true


func _input(_event):
	acc.x = 0
	
	var dir := Vector2(0,0)
	
	if Input.is_action_pressed(input_left):
		$ShrimpGraphic.flip_h = true
		$ShrimpGraphic/ShrimpAnim.speed_scale = 1
		acc.x = -max_acceleration
		dir.x = -1.5
	
	if Input.is_action_pressed(input_right):
		$ShrimpGraphic.flip_h = false
		$ShrimpGraphic/ShrimpAnim.speed_scale = 1
		acc.x = max_acceleration
		dir.x = 1.5
	
	if (dir.x == 0):
		$ShrimpGraphic/ShrimpAnim.speed_scale = 0.5
	
	
	if Input.is_action_just_pressed(input_jump):
		holding_jump = true
		start_jump_buffer_timer()
		if (not can_hold_jump and can_ground_jump()) or can_double_jump():
			jump()
		
	if Input.is_action_just_released(input_jump):
		holding_jump = false
	
	if Input.is_action_pressed("down"):
		dir.y = 1
	
	if Input.is_action_pressed("Up"):
		dir.y = -1
		
	
	#Shoot water
	if Input.is_action_pressed("shoot"):
		
		if (inDash) : return
		if (!can_dash) : return
		
		can_dash = false
		
		print(dir)
		dashDirection = dir
		$DashAnimator.play("Dash")
		
		waterAmount -= 4
		$Graphic/Node2D/Line2D.radius = waterAmount
		$Graphic/Node2D/Line2D.updateWater()
		
		DashWaterDrop = droplet.instantiate()
		DashWaterDrop.waterAmount = 4
		DashWaterDrop.initializeSize()
		
		pass
	


func _physics_process(delta):
	
	if(is_feet_on_ground()): can_dash = true
	
	if inDash :
		
		velocity = dashDirection * dashSpeed
		previous_velocity = velocity
		move_and_slide()
		SquashAndStretch(delta)
		DirectionBuble(delta)
		return
	
	if is_coyote_timer_running() or current_jump_type == JumpType.NONE:
		jumps_left = max_jump_amount
	if is_feet_on_ground() and current_jump_type == JumpType.NONE:
		start_coyote_timer()
		
	# Check if we just hit the ground this frame
	if not _was_on_ground and is_feet_on_ground():
		current_jump_type = JumpType.NONE
		if is_jump_buffer_timer_running() and not can_hold_jump: 
			jump()
		
		hit_ground.emit()
	
	
	# Cannot do this in _input because it needs to be checked every frame
	if Input.is_action_pressed(input_jump):
		if can_ground_jump() and can_hold_jump:
			jump()
	
	var gravity = apply_gravity_multipliers_to(default_gravity)
	acc.y = gravity
	
	# Apply friction
	velocity.x *= 1 / (1 + (delta * friction))
	velocity += acc * delta
	
	
	
	_was_on_ground = is_feet_on_ground()
	$Graphic/Node2D/Line2D.rotationSpeed = clamp(velocity.x * 0.01, -3, 3)
	
	if (apex == null) && (velocity.y > 0) && (!is_feet_on_ground()):
		apex = position
	
	previous_velocity = velocity
	move_and_slide()
	SquashAndStretch(delta)
	DirectionBuble(delta)


## Use this instead of coyote_timer.start() to check if the coyote_timer is enabled first
func start_coyote_timer():
	if is_coyote_time_enabled:
		coyote_timer.start()

## Use this instead of jump_buffer_timer.start() to check if the jump_buffer is enabled first
func start_jump_buffer_timer():
	if is_jump_buffer_enabled:
		jump_buffer_timer.start()

## Use this instead of `not coyote_timer.is_stopped()`. This will always return false if 
## the coyote_timer is disabled
func is_coyote_timer_running():
	if (is_coyote_time_enabled and not coyote_timer.is_stopped()):
		return true
	
	return false

## Use this instead of `not jump_buffer_timer.is_stopped()`. This will always return false if 
## the jump_buffer_timer is disabled
func is_jump_buffer_timer_running():
	if is_jump_buffer_enabled and not jump_buffer_timer.is_stopped():
		return true
	
	return false


func can_ground_jump() -> bool:
	if jumps_left > 0 and current_jump_type == JumpType.NONE:
		return true
	elif is_coyote_timer_running():
		return true
	
	return false


func can_double_jump():
	if jumps_left <= 1 and jumps_left == max_jump_amount:
		# Special case where you've fallen off a cliff and only have 1 jump. You cannot use your
		# first jump in the air
		return false
	
	if jumps_left > 0 and not is_feet_on_ground() and coyote_timer.is_stopped():
		return true
	
	return false


## Same as is_on_floor(), but also returns true if gravity is reversed and you are on the ceiling
func is_feet_on_ground():
	if is_on_floor() and default_gravity >= 0:
		return true
	if is_on_ceiling() and default_gravity <= 0:
		return true
	
	return false


## Perform a ground jump, or a double jump if the character is in the air.
func jump():
	if can_double_jump():
		double_jump()
	else:
		ground_jump()


## Perform a double jump without checking if the player is able to.
func double_jump():
	if jumps_left == max_jump_amount:
		# Your first jump must be used when on the ground.
		# If your first jump is used in the air, an additional jump will be taken away.
		jumps_left -= 1
	
	velocity.y = -double_jump_velocity
	current_jump_type = JumpType.AIR
	jumps_left -= 1
	jumped.emit(false)


## Perform a ground jump without checking if the player is able to.
func ground_jump():
	velocity.y = -jump_velocity
	current_jump_type = JumpType.GROUND
	jumps_left -= 1
	coyote_timer.stop()
	jumped.emit(true)


func apply_gravity_multipliers_to(gravity) -> float:
	if velocity.y * sign(default_gravity) > 0: # If we are falling
		gravity *= falling_gravity_multiplier
	
	# if we released jump and are still rising
	elif velocity.y * sign(default_gravity) < 0:
		if not holding_jump: 
			if not current_jump_type == JumpType.AIR: # Always jump to max height when we are using a double jump
				gravity *= release_gravity_multiplier # multiply the gravity so we have a lower jump
	
	
	return gravity


## Calculates the desired gravity from jump height and jump duration.  [br]
	## Formula is from [url=https://www.youtube.com/watch?v=hG9SzQxaCm8]this video[/url] 
func calculate_gravity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / pow(p_jump_duration, 2)


## Calculates the desired jump velocity from jump height and jump duration.
func calculate_jump_velocity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / (p_jump_duration)


## Calculates jump velocity from jump height and gravity.  [br]
## Formula from 
## [url]https://sciencing.com/acceleration-velocity-distance-7779124.html#:~:text=in%20every%20step.-,Starting%20from%3A,-v%5E2%3Du[/url]
func calculate_jump_velocity2(p_max_jump_height, p_gravity):
	return sqrt(abs(2 * p_gravity * p_max_jump_height)) * sign(p_max_jump_height)


## Calculates the gravity when the key is released based off the minimum jump height and jump velocity.  [br]
## Formula is from [url]https://sciencing.com/acceleration-velocity-distance-7779124.html[/url]
func calculate_release_gravity_multiplier(p_jump_velocity, p_min_jump_height, p_gravity):
	var release_gravity = pow(p_jump_velocity, 2) / (2 * p_min_jump_height)
	return release_gravity / p_gravity


## Returns a value for friction that will hit the max speed after 90% of time_to_max seconds.  [br]
## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_friction(time_to_max):
	return 1 - (2.30259 / time_to_max)


## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_speed(p_max_speed, p_friction):
	return (p_max_speed / p_friction) - p_max_speed

#######################################################################################################################
#added functions

func LoseWater(loss : float):
	
	if (iframe) : return
	
	waterAmount = max(0, waterAmount-loss)
	$BubbleShape.shape.radius = waterAmount
	$Graphic/Node2D/Line2D.radius = waterAmount
	$Graphic/Node2D/Line2D.updateWater()
	
	var l = loss
	
	while l > 0 :
		
		#spawn a bunch of droplet
		var d = droplet.instantiate()
		var value = float(randi_range(1,3))
		
		if (value > l) :
			value = l
		
		l = l - value
		d.waterAmount = value
		d.initializeSize()
		d.position = position #set the droplet position
		var rX = randf_range(-200,200)
		d.linear_velocity = Vector2(rX, -500)
		get_tree().get_root().add_child(d)
		#add impulse to droplet
		
	
	
	iframe = true
	$Iframe.start()
	if (waterAmount == 0):
		return # GAME OVER
	

func gainWater(gain : float):
	
	waterAmount = waterAmount + gain
	
	$BubbleShape.shape.radius = waterAmount
	$Graphic/Node2D/Line2D.radius = waterAmount
	$Graphic/Node2D/Line2D.updateWater()
	
	iframe = true
	$Iframe.start()
	velocity.y -= 500

#Constante
var MAX_DEFORM_SPEED = 2000 #La vitesse y à laquelle la déformation maximal est appliqué

var MAX_SQUASH_DEFORM_VALUE = 2.2 #la déformation maximale
var MIN_SQUASH_DEFORM_VALUE = 1.5 #la déformation minimal

var MAX_STRETCH_DEFORM_VALUE = 1.8 #la déformation maximale
var MIN_STRETCH_DEFORM_VALUE = 0.75 #la déformation minimal

var MIN_TIME_BETWEEN_COLLISION_GROUND = 0.5



#Var
var hit_the_ground = false
var previous_velocity = Vector2() #représente la velocité de la dernière frame
var timeLastGroundCol = 0
@onready var spriteRefNode =  $Graphic/Node2D
@onready var spriteRefLine =  $Graphic

func SquashAndStretch(delta): #A run a chaque frame, defrome le sprite en fonction de la vitesse
	if !is_on_floor() and ((Time.get_unix_time_from_system() - timeLastGroundCol) >MIN_TIME_BETWEEN_COLLISION_GROUND) : #quand ne touche pas le sol
		hit_the_ground = false
	  
		spriteRefNode.scale.y = clamp(remap(abs(velocity.y),0,abs(MAX_DEFORM_SPEED),MIN_STRETCH_DEFORM_VALUE,MAX_STRETCH_DEFORM_VALUE), 0 , 10)
		spriteRefNode.scale.x = clamp(remap(abs(velocity.y),0,abs(MAX_DEFORM_SPEED),1 / MIN_STRETCH_DEFORM_VALUE,1 / MAX_STRETCH_DEFORM_VALUE),0, 10)    
	if not hit_the_ground and is_on_floor() and (Time.get_unix_time_from_system() - timeLastGroundCol >MIN_TIME_BETWEEN_COLLISION_GROUND): 
		hit_the_ground = true
		timeLastGroundCol = Time.get_unix_time_from_system()
		
		spriteRefNode.scale.y = clamp(remap(abs(previous_velocity.y),0,abs(MAX_DEFORM_SPEED * 1.5),1 / MIN_SQUASH_DEFORM_VALUE,1 / MAX_SQUASH_DEFORM_VALUE), 0, 10)
		spriteRefNode.scale.x = clamp(remap(abs(previous_velocity.y),0,abs(MAX_DEFORM_SPEED * 1.5),MIN_SQUASH_DEFORM_VALUE,MAX_SQUASH_DEFORM_VALUE), 0, 10)

	spriteRefNode.scale.y = lerp(spriteRefNode.scale.y, 1.0, 1 - pow(0.01,delta))
	spriteRefNode.scale.x = lerp(spriteRefNode.scale.x, 1.0, 1 - pow(0.01,delta))


var angleDirectionTheorique:float = 0.0
var angleDirectionPratique:float = 0.0

var VecUp = Vector2(0,1)


var VITESSE_ROTATION_BULLE = 0
var MIN_SPEED_ROTATION = 50

func DirectionBuble(delta):
	if is_on_floor():
		angleDirectionTheorique = 0
		angleDirectionPratique = 0
	elif velocity.length() > MIN_SPEED_ROTATION :
		angleDirectionTheorique = clamp(rad_to_deg(VecUp.angle_to(velocity)),-20,20)
	else :
		angleDirectionTheorique = 0
		angleDirectionPratique = 0
		#print("speedTooLow")
	if (velocity.y > 0 ) :
		angleDirectionTheorique = angleDirectionTheorique
	else :
		angleDirectionTheorique = -angleDirectionTheorique
	angleDirectionPratique = move_toward(angleDirectionPratique,angleDirectionTheorique,delta*VITESSE_ROTATION_BULLE)
	spriteRefLine.rotation_degrees = angleDirectionPratique
	
	#print("angleDirectionTheorique = ",angleDirectionTheorique)
	#print("spriteRef.rotation_degrees = ",spriteRefLine.rotation_degrees)
	

######################################################################################################################


func _on_hit_ground():
	if apex != null :
		
		if (position.y - apex.y) > 100:
			
			LoseWater(6)
		
	
	apex = null


func _on_iframe_timeout():
	iframe = false
	pass # Replace with function body.


func releaseWaterDrop():
	
	DashWaterDrop.position = position
	DashWaterDrop.linear_velocity = -dashDirection * dashSpeed
	get_tree().get_root().add_child(DashWaterDrop)
	
