extends Label

var ip_address = ""

func _on_Join_button_pressed():
	Network.ipAdress = ip_address
	Network.join_server()
	get_parent().get_parent().queue_free()
