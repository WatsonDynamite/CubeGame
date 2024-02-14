extends Node3D

var cur_space;
@onready var shapecast: ShapeCast3D = $ShapeCast3D
@onready var inventory = $"../Inventory";
@onready var anim_tree = $"../AnimationTree";
#TODO: grab weapon from inventory system and place it here;
@onready var model = $"../Model";
@onready var character;

# hacky way to do this, but the is_visible property of this node
# controls whether we can cancel from an attack to the next
@onready var can_cancel = $can_cancel;

func _ready():
	can_cancel.set_visible(true);
	character = get_parent();
	pass;

func _process(_delta):
	#rotate this node with player model rotation
	rotation_degrees = Vector3(0, model.rotation_degrees.y + 180 , 0);
	
	_set_attack_window(can_cancel.is_visible_in_tree() && Input.is_action_just_pressed("attack_1"));


func _physics_process(_delta):
	cur_space = character.get_world_3d().direct_space_state;
	
func _perform_attack(hitstun: int, dmg_mod: int, knockback: Vector3): #TODO: pass attack as func param
	#apply a small impulse to player
	character.velocity = global_basis * Vector3(0, 0, -1).normalized();
	if(shapecast && shapecast.is_colliding()):
		var collision = shapecast.get_collider(0);
		if(collision && collision.is_in_group("Enemy") && collision.has_method("receive_damage")):
			var attack:Attack = Attack.new(hitstun, dmg_mod, knockback);
			#pass player rotation, used for knockback calc
			collision.receive_damage(attack, Vector3.FORWARD.signed_angle_to(global_basis.z, Vector3.UP));			
	pass;

func _set_attack_window(new_value: bool):
	anim_tree.set("parameters/conditions/can_next_attack", new_value);
	#TODO: change to get the animation set from the equipped weapon
	anim_tree.set("parameters/AnimSet1Atk1/conditions/can_next_attack", new_value);
	anim_tree.set("parameters/AnimSet1Atk1/conditions/cannot_next_attack", !new_value);
	
	
	
