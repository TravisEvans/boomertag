extends Area3D

class_name Hitbox

signal hurt

@export var weak_spot = false
@export var critical_damage_multiplier = 2.0

func _hurt(damage: float, dir: Vector3):
	if weak_spot:
		emit_signal("hurt", damage * critical_damage_multiplier, dir)
	else:
		emit_signal("hurt", damage, dir)
