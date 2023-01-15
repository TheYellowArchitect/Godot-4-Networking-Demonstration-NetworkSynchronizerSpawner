extends Node3D

var multiplayer_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

const PORT = 9999
const ADDRESS = "127.0.0.1"

var connected_peer_ids = []
var local_player_character : Node3D

func _on_host_pressed():
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	#UI Stuff
	$NetworkInfo/NetworkSideDisplay.text = "Server"
	$Menu.visible = false
	$NetworkInfo/UniquePeerID.text = str(multiplayer.get_unique_id())
	
	add_player_character(1)
	
	multiplayer_peer.peer_connected.connect(_on_peer_connected)
	multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(new_peer_id : int):
	connected_peer_ids.append(new_peer_id)
	var new_player_character : Node3D = add_player_character(new_peer_id)
	
func _on_peer_disconnected(left_peer_id : int):
	$Players.get_node(str(left_peer_id)).queue_free()
	
func _on_join_pressed():
	multiplayer_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	#UI Stuff
	$NetworkInfo/NetworkSideDisplay.text = "Client"
	$Menu.visible = false
	$NetworkInfo/UniquePeerID.text = str(multiplayer.get_unique_id())

func add_player_character(peer_id : int) -> Node3D:
	var player_character : Node3D = preload("res://player_character/player_character.tscn").instantiate()
	player_character.name = str(peer_id)
	
	#By creating a Player locally on $Players
	#PlayerSpawner node spawns every new child of $Players, onto clients!
	$Players.add_child(player_character)
	
	return player_character

func _on_message_input_text_submitted(new_text: String) -> void:
	local_player_character.rpc("display_message", new_text)
	
	#Reset the UI input
	$MessageInput.text = ""
	$MessageInput.release_focus()
