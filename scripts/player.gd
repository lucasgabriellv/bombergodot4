extends CharacterBody2D

@export var speed = 135
var screen_size
var dead: bool = false

signal bomb_placed

func _ready():
	screen_size = get_viewport_rect().size
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
func _process(_delta):
	if dead:
		return

	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	do_movement(input_dir)
	do_sprites(input_dir)

func do_movement(input_dir: Vector2):
	if Input.is_action_just_pressed("place_bomb"):
		place_bomb()
	
	velocity = input_dir * speed
	move_and_slide()
	position = position.clamp(Vector2.ZERO, screen_size)

func do_sprites(input_dir: Vector2):
	if input_dir.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.animation = "idle"

	if input_dir.x != 0:
		$AnimatedSprite2D.animation = "walk-side"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = input_dir.x < 0
	elif input_dir.y != 0:
		$AnimatedSprite2D.flip_v = false
		if input_dir.y > 0:
			$AnimatedSprite2D.animation = "walk-down"
		else:
			$AnimatedSprite2D.animation = "walk-up"

func place_bomb():
	bomb_placed.emit()
	
func died():
	print('You died.')
	dead = true
	hide()
	queue_free()
