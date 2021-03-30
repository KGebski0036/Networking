extends Node


const DefaultPort = 2233
const MaxPlayers = 6

var server = null
var client = null

var ipAdress = ""
var player_username = ""

var network_object_name_index = 0 setget set_network_object_name_index
puppet var puppet_network_object_name_index = 0 setget set_puppet_network_object_name_index

func _ready():
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("10.147.") and not ip.ends_with(".1"):
			ipAdress = ip
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

	
func _connected_to_server() -> void:
	print("Yes")
	
func _server_disconnected() -> void:
	print("Yes but actually no")
	
func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DefaultPort, MaxPlayers)
	get_tree().set_network_peer(server)
	Global.instance_node(load("res://Server_advertiser.tscn"), get_tree().current_scene)
	
func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ipAdress, DefaultPort)
	get_tree().set_network_peer(client)
	
func set_puppet_network_object_name_index(new_value):
	network_object_name_index = new_value
	
func set_network_object_name_index(new_value):
	network_object_name_index = new_value
	
	if get_tree().is_network_server():
		rset("puppet_network_object_name_index", network_object_name_index)
