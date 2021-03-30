extends Node

signal new_server
signal remove_server

var clean_up_timer = Timer.new()
var socket_udp = PacketPeerUDP.new()
var listen_port = Network.DefaultPort
var known_servers = {}

export (int) var server_cleanup_threshold = 3

func _init():
	clean_up_timer.wait_time = server_cleanup_threshold
	clean_up_timer.one_shot = false
	clean_up_timer.autostart = true
	clean_up_timer.connect("timeout", self, 'clean_up')
	add_child(clean_up_timer)
	
func _ready():
	known_servers.clear()
	
	if socket_udp.listen(listen_port) != OK:
		print("GameServer Error on port:" + str(listen_port))
	else:
		print("GameServer Ok on port:" + str(listen_port))
		
func _process(delta):
	if socket_udp.get_available_packet_count() > 0:
		var server_ip = socket_udp.get_packet_ip()
		var server_port = socket_udp.get_packet_port()
		var array_bytes = socket_udp.get_packet()

		if server_ip != '' and server_port > 0:
			if not known_servers.has(server_ip):
				var serverMessage = array_bytes.get_string_from_ascii()
				var gameInfo = parse_json(serverMessage)
				gameInfo.ip = server_ip
				gameInfo.lastSeen = OS.get_unix_time()
				known_servers[server_ip] = gameInfo
				emit_signal("new_server", gameInfo)
				print(socket_udp.get_packet_ip())
			else:
				var gameInfo = known_servers[server_ip]
				gameInfo.lastSeen = OS.get_unix_time()
func clean_up():
	var new = OS.get_unix_time()
	for server_ip in known_servers:
		var serverInfo = known_servers[server_ip]
		if (new - serverInfo.lastSeen) > server_cleanup_threshold:
			known_servers.erase(server_ip)
			print('Remove old sserver: %s' % server_ip)
			emit_signal("remove_server", server_ip)
			
func _exit_tree():
	socket_udp.close()
				