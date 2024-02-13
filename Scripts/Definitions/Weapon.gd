extends Node;

class_name Weapon;

var wep_type: CombatEnums.WeaponType;
var wep_element: CombatEnums.Elements;

func _get_attack_damage():
	pass;

func _get_animation_set():
	match(wep_type):
		[CombatEnums.WeaponType.SWORD, CombatEnums.WeaponType.AXE, CombatEnums.WeaponType.MACE]:
			return "AnimSet1";
		CombatEnums.WeaponType.DAGGERS:
			return "AnimSet2";
		[CombatEnums.WeaponType.GREATSWORD, CombatEnums.WeaponType.GREATAXE, CombatEnums.WeaponType.WARHAMMER]:
			return "AnimSet3";
		CombatEnums.WeaponType.SPEAR:
			return "AnimSet4";
		CombatEnums.WeaponType.BOW:
			return "AnimSet5";
		CombatEnums.WeaponType.CHAKRAM:
			return "AnimSet6";
		[CombatEnums.WeaponType.CROSSBOW, CombatEnums.WeaponType.RIFLE]:
			return "AnimSet7";
		CombatEnums.WeaponType.GRIMOIRE:
			return "AnimSet8";
		[CombatEnums.WeaponType.STAFF, CombatEnums.WeaponType.TALISMAN]:
			return "AnimSet9";
		_:
			return "AnimSet1";	
