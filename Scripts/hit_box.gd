extends Area3D

class_name Hitbox

signal tagged

#@export var weak_spot = false
#@export var critical_damage_multiplier = 2.0
@export var can_tag = false


func _ready():
	area_shape_entered.connect(on_body_entered)
	collision_layer = 2
	collision_mask = 2

func on_body_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int):
	if area.get_multiplayer_authority() != multiplayer.get_unique_id() and area.can_tag:
		#print("tagged by " + str(area.get_multiplayer_authority()))
		tag(area, area.get_multiplayer_authority())

func tag(area: Area3D, peer: int):
	#if weak_spot:
		#emit_signal("hurt", damage * critical_damage_multiplier, dir)
	#else:
	print("tagged by " + str(area.get_multiplayer_authority()))
	emit_signal("tagged")
