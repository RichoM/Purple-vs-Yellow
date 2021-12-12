extends Control

var url = "ws://127.0.0.1:9080"

onready var labels = [$left/data/label, $right/data/label]
var clients = [null, null]

func _process(delta):
	pass

func _on_connect_pressed(id):
	if clients[id] != null: 
		append(id, "ERROR: Already connected")
		return
	clients[id] = WebSocketClient.new()
	clients[id].connect("connection_closed", self, "_closed_" + str(id))
	clients[id].connect("connection_error", self, "_closed_" + str(id))
	clients[id].connect("connection_established", self, "_connected_" + str(id))
	var err = clients[id].connect_to_url(url)
	if err != OK:
		append(id, "ERROR: Unable to connect")
		clients[id] = null

func _on_disconnect_pressed(id):
	if clients[id] == null:
		append(id, "ERROR: Not connected")
		return
	var client : WebSocketClient = clients[id]
	client.disconnect_from_host()

func _on_ping_pressed(id):
	append(id, str("PING: ", id))

func append(id, text):
	labels[id].text += str(text, "\n")

func _closed_0():
	append(0, "DISCONNECTED!")

func _closed_1():
	append(1, "DISCONNECTED!")
	
func _connected_0():
	append(0, "CONNECTED!")
	
func _connected_1():
	append(1, "CONNECTED!")
