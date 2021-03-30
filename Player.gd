extends KinematicBody2D

var speed = 300
var hp = 100 setget set_hp

var velocity = Vector2.ZERO
var can_shoot = true
var is_reloading = false

var player_bullet = load("res://Player_bullet.tscn")

onready var tween = $Tween
onready var sprite = $Sprite
onready var reload_timer = $Reload_timer
onready var shoot_point = $Shoot_point
onready var hit_timer = $Hit_timer

puppet var puppet_hp = 100 setget set_puppet_hp 
puppet var puppet_position = Vector2.ZERO setget puppet_position_set
puppet var puppet_rotation = 0
puppet var puppet_velocity = Vector2.ZERO

func _ready():
	update_shoot_mode(false)

func _process(delta: float) -> void:
	if is_network_master():
		var x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		var y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		 
		speed = 300
		if Input.is_action_pressed("sprint"):
			speed *= 2
			
		
		velocity = Vector2(x,y).normalized()
		
		move_and_slide(velocity * speed)
		
		look_at(get_global_mouse_position())
		
		if Input.is_action_pressed("click") and can_shoot and not is_reloading:
			rpc("instance_bullet", get_tree().get_network_unique_id())
			is_reloading = true
			reload_timer.start()
	else:
		rotation = lerp_angle(rotation, puppet_rotation, delta * 8)
		
		if not tween.is_active():
			move_and_slide(puppet_velocity * speed)
			
func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()
	
func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation)
		rset_unreliable("puppet_velocity", velocity)

sync func instance_bullet(id):
	var player_bullet_instance = Global.instance_node_at_location(player_bullet, Persistent_node, shoot_point.global_position)
	player_bullet_instance.name = "Bullet" + name + str(Network.network_object_name_index)
	player_bullet_instance.set_network_master(id)
	player_bullet_instance.player_rotation = rotation
	player_bullet_instance.player_owner = id
	Network.network_object_name_index += 1
	
func update_shoot_mode(shoot_mode):
	if not shoot_mode:
		sprite.set_region_rect(Rect2(0,1500,256,250))
	else:
		sprite.set_region_rect(Rect2(512,1500,256,250))
		
	can_shoot = shoot_mode
	
func set_hp(new_value):
	hp = new_value
	if is_network_master():
		rset("puppet_hp", hp)
		
func set_puppet_hp(new_value):
	puppet_hp = new_value
	if not is_network_master():
		hp = puppet_hp
		
func _on_Reload_timer_timeout():
	is_reloading = false

func _on_Hit_timer_timeout():
	modulate = Color(1,1,1,1)

func _on_Hitbox_area_entered(area):
	if get_tree().is_network_server():
		if area.is_in_group("player_damager") and area.get_parent().player_owner != int(name):
			rpc("hit_by_damager", area.get_parent().damage)
			area.get_parent.rpc("destroy")
			
sync func hit_by_damger(damage):
	hp -= damage
	modulate = Color(5,5,5,1)
	hit_timer.start()
	
	
