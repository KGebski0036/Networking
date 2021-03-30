extends Control

var player = load("res://Player.tscn")

onready var multiplayer_config_ui = $Multi_Conf
onready var username_text = $Multi_Conf/Username_text
onready var device_ip_address = $CanvasLayer/Devce_ip
onready var start_game = $CanvasLayer/Start_game

func _ready():
	get_tree().connect("network_peer_connected",self, "_player_conected")
	get_tree().connect("network_peer_disconnected",self, "_player_disconected")
	get_tree().connect("connected_to_server",self, "_connected_to_server")
	
	device_ip_address.text = Network.ipAdress
	
	if get_tree().network_peer == null:
		start_game.hide()
		
func _process(delta):
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
			start_game.show()
		else:
			start_game.hide()
	
func _player_conected(id):
	print("Player " + str(id) + " has connected")
	instance_player(id)
	
func _player_disconected(id):
	print("Player " + str(id) + " has disconnected")
	if Persistent_node.has_node(str(id)):
		Persistent_node.get_node(str(id)).queue_free()
		
func _connected_to_server():
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())
	
func _on_Create_Server_pressed():
	if not (username_text.text == ""):
		Network.player_username = username_text.text
		multiplayer_config_ui.hide()
		Network.create_server()
	
		instance_player(get_tree().get_network_unique_id())

func _on_Join_Server_pressed():
	if username_text.text != "":
		multiplayer_config_ui.hide()
		username_text.hide()
		Global.instance_node(load("res://Server_browser.tscn"), self)
		
func instance_player(id) -> void:
	var player_instance = Global.instance_node_at_location(player, Persistent_node, Vector2(rand_range(0,1920),rand_range(0,1080)))
	player_instance.name = str(id)
	player_instance.set_network_master(id)

func _on_Start_game_pressed():
	rpc("switch_to_game")
	
sync func switch_to_game() ->void:
	for child in Persistent_node.get_children():
		if child.is_in_group("player"):
			child.update_shoot_mode(true)
	get_tree().change_scene("res://Game.tscn")
