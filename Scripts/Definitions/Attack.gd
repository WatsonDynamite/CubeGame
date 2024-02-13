extends Resource;

class_name Attack;
var hitstun: int;
var damage_mod: float;
var knockback: Vector3;

func _init(hs, dmg, kb):
	hitstun = hs;
	damage_mod = dmg;
	knockback = kb;
