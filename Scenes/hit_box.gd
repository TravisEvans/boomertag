extends Area3D

class_name Hitbox

signal hit

#@export var weak_spot = false
#@export var critical_damage_multiplier = 2.0
@export var can_tag = false

func _hit(damage: float, dir: Vector3):
	#if weak_spot:
		#emit_signal("hurt", damage * critical_damage_multiplier, dir)
	#else:
	emit_signal("hit", damage, dir)
