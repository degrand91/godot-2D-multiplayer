extends KinematicBody2D

var speed = 200  # speed in pixels/sec
var velocity = Vector2.ZERO
export var is_controlled = false
func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	
	

func _physics_process(delta):
	if is_controlled:
		get_input()
		rpc_unreliable("network_update", transform)
	# Make sure diagonal movement isn't faster
	velocity = velocity.normalized() * speed
	velocity = move_and_slide(velocity)
	
sync func network_update(new_transform):
	transform = new_transform
