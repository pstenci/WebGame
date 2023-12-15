extends CharacterBody3D
const speed:float=6.0
const jump:int=10
const follow_lerp_fact:float=4.0
const push_force:float=0.5
const weight:float=4.5
const move_speed:float=4.0
var is_grounded = false
var can_double_jump = false

# Onready Variables
@onready var model = $pm
@onready var animation = $pm/AnimationPlayer
@onready var spring_arm = %SpringArm
#@onready var camera = %Gimbal/Camera3D

#@onready var particle_trail = $ParticleTrail
#@onready var footsteps = $Footsteps

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

# ---------- FUNCTIONS ---------- #

func _process(delta):
	player_animations()
	get_input(delta)
	
	# Smoothly follow player's position
	spring_arm.position = lerp(spring_arm.position, position, delta * follow_lerp_fact)
	var look_direction = Vector2(velocity.z, velocity.x)
	
	model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, delta * 12)

	
	# Check if player is grounded or not
	is_grounded = true if is_on_floor() else false
	
	# Handle Jumping
	if is_grounded:
		can_double_jump = false
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			perform_jump()

	if Input.is_action_just_released("jump"):
		if (velocity.y>0):
			velocity.y*=0.7
	velocity.y -= gravity * delta

func perform_jump():
	#AudioManager.jump_sfx.play()
	#AudioManager.jump_sfx.pitch_scale = 1.12
	
	#jumpTween()
	animation.play("Jump")
	velocity.y = jump


func is_moving():
	return abs(velocity.z) > 0 || abs(velocity.x) > 0

#func jumpTween():
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "scale", jumpStretchSize, 0.1)
	#tween.tween_property(self, "scale", Vector3(1,1,1), 0.1)

# Get Player Input
func get_input(_delta):
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_axis("move_left", "move_right")
	move_direction.z = Input.get_axis("move_foward", "move_back")
	
	# Move The player Towards Spring Arm/Camera Rotation
	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	velocity = Vector3(move_direction.x * move_speed, velocity.y, move_direction.z * move_speed)
	move_and_slide()
	for i in get_slide_collision_count():
		var c=get_slide_collision(i)
		if c.get_collider() is RigidBody3D:	
			if c.get_collider().position.y>=position.y: 
				c.get_collider().apply_central_impulse(-c.get_normal()*push_force)
			else: c.get_collider().apply_central_force(-c.get_normal()*weight)
	#var collision = move_and_collide(velocity * _delta)
	#if collision:
		#velocity = velocity.slide(collision.get_normal())

# Handle Player Animations
func player_animations():
	#particle_trail.emitting = false
	#footsteps.stream_paused = true
	
	if is_on_floor():
		if is_moving(): # Checks if player is moving
			animation.play("CutCatWalkA", 0.5)
			#particle_trail.emitting = true
		#	footsteps.stream_paused = false
		else:
			animation.play("CuCatIdleA", 0.5)
