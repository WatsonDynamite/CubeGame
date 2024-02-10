extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 10;
const FRICTION = 6;
const ACCELERATION = 4;
const AIRACCEL = 3;
const TURNACCEL = 10


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var spring_arm: SpringArm3D;
var model: Node3D;
var body_bone: Node3D;
var anim_tree: AnimationTree;


func _ready():
	spring_arm = get_node("CameraPivot/CameraArm");
	spring_arm.add_excluded_object(get_rid());
	model = get_node("Model");
	anim_tree = get_node("AnimationTree");
	pass;



func _physics_process(delta):
	var aux_velocity: Vector3 = velocity;
	var accel_to_use;

	# add the gravity
	if(!is_on_floor()):
		anim_tree.active = false; #change this when implementing attack animations
		aux_velocity.y -= gravity * delta;
		accel_to_use = AIRACCEL;
	else:
		anim_tree.active = true;
		accel_to_use = ACCELERATION;

	# handle jump
	if(Input.is_action_just_pressed("ui_accept") && is_on_floor()):
		aux_velocity.y = JUMP_VELOCITY;
	
	# get the input direction and handle movement/deceleration
	# replace UI actions with custom actions (input map)

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	var direction = spring_arm.basis * Vector3(input_dir.x, 0, input_dir.y).normalized();
	aux_velocity.x = lerp(aux_velocity.x, direction.normalized().x * SPEED, accel_to_use * delta);
	aux_velocity.z = lerp(aux_velocity.z, direction.normalized().z * SPEED, accel_to_use * delta);

	velocity = aux_velocity

	# set animation on blend tree
	# we convert the velocity value to a value between 0 and 1 by dividing the absolute
	# by our speed constant

	anim_tree.set("parameters/Movement/blend_position", abs(velocity.length() / SPEED));

	move_and_slide();

	if Vector2(aux_velocity.x, aux_velocity.z).length() > 0.2:
		# Code for various player model rotations
		#	- The player model needs to turn to face the movement direction
		#	- However we also have a cosmetic tilt of the character's body when the player turns
		#	- to do this, we rotate the body bone around the Z axis in the angle formed by the model's current forward
		#		and the movement vector's forward
		#	- we need to make a copy of the movement vector with no Y axis to make it always face upward
		#		otherwise the simple act of falling will cause the player to tilt as the velocity vector 
		#		will have a 180 degree angle with the model's forward vector

		var aux_velocity_facing_up: Vector3 = Vector3(aux_velocity.x, 0, aux_velocity.z);
		# Angle in degrees between the movement direction and the model's forward direction
		# We clamp the able because we don't want more than a 30 degree tilt
		var direction_angle = clamp(rad_to_deg(aux_velocity_facing_up.signed_angle_to(model.global_basis.z, Vector3.UP)), -30, 30);
		# amount to tilt the player model
		var tilt_lerp_angle = lerp_angle(model.rotation.z, deg_to_rad(direction_angle), delta * TURNACCEL);


		# rotate player model
		model.rotation = Vector3(
			model.rotation.x, # X
			# from what I can tell, atan2() does something similar to lerp_angle
			# I don't know for sure because this part came from a tutorial
			lerp_angle(model.rotation.y, atan2(aux_velocity.x, aux_velocity.z), delta * TURNACCEL), # Y
			tilt_lerp_angle # Z
		)
	pass;

	
