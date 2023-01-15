extends MeshInstance3D

#_enter_tree() runs always before _ready()
#Hence, there is no delay from node creation to setting multiplayer authority
#For example, try moving `set_multiplayer_authority` onto ready()
#and see the error where MultiplayerSynchronizer
#tried to fetch it right there but no networkID!
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _ready():
	$Name.text = str(name)
	
	if name.to_int() == multiplayer.get_unique_id():
		get_parent().get_parent().local_player_character = self

func _physics_process(delta):
	if is_multiplayer_authority():
		var direction:Vector3 = Vector3.ZERO
		
		if Input.is_key_pressed(KEY_W):direction.z -= 1
		if Input.is_key_pressed(KEY_S):direction.z += 1
		if Input.is_key_pressed(KEY_A):direction.x -= 1
		if Input.is_key_pressed(KEY_D):direction.x += 1
		
		global_position += direction.normalized()

@rpc(authority, call_local, reliable, 1)
func display_message(message):
	$Message.text = str(message)
	
@rpc(any_peer, call_local, reliable, 1)
func clicked_by_player():
	$Message.text = str(multiplayer.get_remote_sender_id()) + " clicked on me!"



func _on_mouse_click_area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		rpc("clicked_by_player")
