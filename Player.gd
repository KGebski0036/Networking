extends KinematicBody2D

const speed = 300

var velocity = Vector2.ZERO

onready var tween = $Tween

puppet var puppet_position = Vector2.ZERO setget puppet_position_set
puppet var puppet_rotation = 0
puppet var puppet_velocity = Vector2.ZERO
func _process(delta: float) -> void:
	if is_network_master():
		var x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		var y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		
		velocity = Vector2(x,y).normalized()
		
		move_and_slide(velocity * speed)
		
		look_at(get_global_mouse_position())
	else:
		rotation_degrees = lerp(rotation_degrees, puppet_rotation, delta * 8)
		
		if not tween.is_active():
			move_and_slide(puppet_velocity * speed)

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()
	
func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation_degrees)
		rset_unreliable("puppet_velocity", velocity)
