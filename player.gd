extends CharacterBody3D

# References to camera nodes (use % for unique names if set in the editor)
@onready var camera_pivot: Node3D = %"Camera Pivot"
@onready var camera: Camera3D = %Camera3D

const speed = 5.0

# Mouse sensitivity and limits (tweak these in the inspector)
@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.002  # Adjust for feel (e.g., 0.002 for smooth)
@export var max_tilt: float = deg_to_rad(85.0)  # Max vertical tilt in radians (e.g., 85° up/down)

func _ready() -> void:
	# Capture the mouse for smooth rotation (hides cursor and locks it to window)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Horizontal rotation (yaw) around the player
		camera_pivot.rotation.y -= event.relative.x * mouse_sensitivity
		
		# Vertical rotation (pitch) with clamping to prevent flipping

# Optional: Toggle mouse capture with a key (e.g., Esc to free mouse for menus)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # Default Esc key
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
func _physics_process(delta: float) -> void:
	# Get input direction: x = left/right, y = forward/back
	var input_dir = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	
	if input_dir == Vector2.ZERO:
		velocity.x = move_toward(velocity.x, 0, speed)  # Optional: Decelerate when no input
		velocity.z = move_toward(velocity.z, 0, speed)
		move_and_slide()
		return
	
	# Camera-relative directions (projected to ground)
	var cam_xform = camera.global_transform.basis
	var forward = -cam_xform.z  # Camera's facing direction (away from camera)
	forward.y = 0  # Flatten to ground
	forward = forward.normalized()
	
	var right = cam_xform.x  # Camera's right direction
	right.y = 0
	right = right.normalized()
	
	# Combine for movement
	var direction = (right * input_dir.x + forward * input_dir.y).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	move_and_slide()
