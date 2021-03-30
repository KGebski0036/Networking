extends Control

onready var server_listener = $Server_lisiner
onready var server_ip_text = $Background/Server_ip
onready var server_container = $Background/VBoxContainer
onready var manual_setup_button = $Background/Manual_setup

func _ready():
	server_ip_text.hide()

func _on_Server_lisiner_new_server(serverInfo):
	var server_node = Global.instance_node(load("res://Server_disply.tscn"), server_container)
	server_node.text = "%s - %s" % [serverInfo.ip, serverInfo.name]
	server_node.ipAdress = str(serverInfo.ip)


func _on_Server_lisiner_remove_server(serverIp):
	for serverNode in server_container.get_children():
		if serverNode.is_in_group("Server_display"):
			if serverNode.ipAdress == serverIp:
				serverNode.queue_free()
				break


func _on_Manual_setup_pressed():
	if manual_setup_button.text != "exit setup":
		server_ip_text.show()
		manual_setup_button.text = "exit setup"
		server_container.hide()
		server_ip_text.call_deferred("grab focus")
	else:
		server_ip_text.text = ""
		server_ip_text.hide()
		manual_setup_button.text = "manual setup"
		server_container.show()


func _on_Join_server_pressed():
	Network.ipAdress = server_ip_text.text
	hide()
	Network.join_server()


func _on_Back_pressed():
	get_tree().reload_current_scene()
