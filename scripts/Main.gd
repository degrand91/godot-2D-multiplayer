extends Node

# Port must be open in router settings
const PORT = 27015
const MAX_PLAYERS = 32

# To play over internet check your IP and change it here
export var ip : String = "localhost"
# To use a background server download the server export template without graphics and audio from:
# https://godotengine.org/download/server
# And choose it as a custom template upon export
export var background_server : bool = false

onready var player_scene = preload("res://scenes/Player.tscn")

var network = NetworkedMultiplayerENet.new()

func _ready():
	# If we are exporting this game as a server for running in the background
	if background_server:
		# Just create server
		create_server()
		# To keep it simple we are creating an uncontrollable server's character to prevent errors
		# TO-DO: Create players upon reading configuration from the server
#		create_player(1, false)
	else:
		# Elsewise connect menu button events
		var _host_pressed = $Ui/MainMenu/Host.connect("pressed", self, "_on_host_pressed")
		var _connect_pressed = $Ui/MainMenu/Connect.connect("pressed", self, "_on_connect_pressed")
		var _quit_pressed = $Ui/MainMenu/Quit.connect("pressed", self, "_on_quit_pressed")
		

func _on_host_pressed():
	# Create the server
	create_server()
	# Create our player, 1 is a reference for a host/server
	create_player(1, false)
	# Hide a menu
	$Ui/MainMenu.visible = false
	$Ui/Output.text = "you are the server"

# When Connect button is pressed
func _on_connect_pressed():
	# Connect network events
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var _connected_to_server = get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	var _connection_failed = get_tree().connect("connection_failed", self, "_on_connection_failed")
	var _server_disconnected = get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	
	network.create_client(ip, PORT)
	get_tree().set_network_peer(network)

func _on_quit_pressed():
	# Quitting the game
	get_tree().quit()


func create_server():
	# Connect network events
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	# Set up an ENet instance
	network.create_server(PORT, MAX_PLAYERS - 1)
	get_tree().set_network_peer(network)

func _on_connected_to_server():
	# Upon successful connection get the unique network ID
	# This ID is used to name the character node so the network can distinguish the characters
	var id = get_tree().get_network_unique_id()
	$Ui/Output.text = "Connected! ID: " + str(id)
	# Hide a menu
	$Ui/MainMenu.visible = false
	# Create a player
	create_player(id, false)

func _on_connection_failed():
	# Upon failed connection reset the RPC system
	get_tree().set_network_peer(null)
	$Ui/Output.text = "Connection failed"



func _on_peer_connected(id):
	# When other players connect a character and a child player controller are created
	create_player(id, true)

func _on_peer_disconnected(id):
	# Remove unused nodes when player disconnects
	remove_player(id)
	pass

func create_player(id, is_peer):
	var player = player_scene.instance()
	player.name = str(id)
	$Players.add_child(player)
	if !is_peer:
		player.get_node("Camera2D").current = true
		player.is_controlled = true
#	player.global_transform.origin = random_point(40, 20)
	
func remove_player(id):
	# Remove unused characters
	$Players.get_node(str(id)).free()
	
func random_point(area, height):
	# Random point within some area units
	randomize()
	return Vector3(rand_range(-area, area), height, rand_range(-area, area))
