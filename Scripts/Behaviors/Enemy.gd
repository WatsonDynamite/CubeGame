extends CharacterBody3D

const MAX_REVENGE = 15;
const MAX_HP = 9999;
const MAX_POISE = 2;

const FRICTION = 4;

var cur_revenge := MAX_REVENGE;
var cur_hp := MAX_HP;
var cur_poise := MAX_POISE;
var cur_hitstun := 0;

var is_getting_comboed: bool = false;

@onready var hp_label = $Labels/HPLabel;
@onready var hit_stun_label = $Labels/HitStunLabel;
@onready var poise_label = $Labels/PoiseLabel;
@onready var revenge_label = $Labels/RevengeLabel;
@onready var particles = $Particles;

var particle_counter = 0;
var model;

var default_gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var gravity = default_gravity;

func _ready():
	model = get_node("Model");

func _physics_process(delta):
	do_labels();
	do_hitstun();
	velocity.y -= gravity * delta;
	
	velocity.x = lerp(velocity.x, 0.0, FRICTION * delta);
	velocity.z = lerp(velocity.z, 0.0, FRICTION * delta);
	
	
	cur_hp = clamp(cur_hp, 0, MAX_HP);
	cur_poise = clamp(cur_poise, 0, MAX_POISE);
	cur_revenge = clamp(cur_revenge, 0, MAX_REVENGE);
	
	do_combat_values();
	move_and_slide();
	pass;
	
func do_labels():
	hp_label.text = 'HP: '+ str(cur_hp);
	hit_stun_label.text = 'Hitstun: ' + str(cur_hitstun);
	poise_label.text = 'Poise: ' + str(cur_poise);
	revenge_label.text = 'Revenge: ' + str(cur_revenge);
	pass;

func do_hitstun():
	if(cur_revenge == 0):
		is_getting_comboed = false;
	if(is_getting_comboed):
		# TODO: add a hitstun animation and use that instead
		# probably place it in the receive_damage method
		model.rotation.x = -30;
		if (cur_hitstun > 0):
			cur_hitstun -= 1;
		if(cur_hitstun == 0):
			is_getting_comboed = false;
	else:
		model.rotation.x = 0;
	pass;
	
func do_combat_values():
	if(cur_revenge <= 0):
		cur_revenge = MAX_REVENGE;
		cur_poise = MAX_POISE;
	pass;

func receive_damage(attack: Attack, attacker_rot: float): #TODO: add Attack as a parameter
	#TODO: replace with damage formula
	cur_hp -= 1; 
	cur_poise -= 1;
	
	 #TODO: replace hitstun, etc. with attack properties
	cur_hitstun = attack.hitstun;
	
	velocity = Vector3.ZERO;
	if(cur_poise <= 0):
		is_getting_comboed = true;
	if(is_getting_comboed):
		_emit_hit_particle();
		cur_revenge -= 1;
		gravity = default_gravity / 2;
		print(attacker_rot);
		velocity = attack.knockback.rotated(Vector3(0, 1, 0), attacker_rot);
	pass;


func _emit_hit_particle():
	if particle_counter == particles.get_child_count():
		particle_counter = 0;
	particles.get_child(particle_counter).set_emitting(true);
	if(particle_counter > 0):
		particles.get_child(particle_counter - 1).restart();
	particle_counter+=1;
	pass;

func _die():
	print("dead");
