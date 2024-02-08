extends CharacterBody3D

var direction = Vector3.FORWARD

func _physics_process(delta):
        direction = Vector3(Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"))