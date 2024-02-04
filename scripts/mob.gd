extends Area2D

signal player_hit_by_mob

@export var direction: Vector2
var speed = 60
var direction_change_chance = 20 # 20 = 20%
var change_direction: bool = false

func _ready():
	$AnimatedSprite2D.animation = "default"
	$AnimatedSprite2D.play()

func _process(delta):
	position += direction * speed * delta
	if not change_direction:
		return

	if abs(direction.x) > 0 and int(position.x) % 32 == 0:
		position.x = int(position.x)
		direction.y = direction.x
		direction.x = 0
		change_direction = false		
	elif abs(direction.y) > 0 and int(position.y) % 32 == 0:
		position.y = int(position.y)
		direction.x = direction.y
		direction.y = 0
		change_direction = false
	
func _on_body_entered(body):
	if body.name == "Player":
		player_hit_by_mob.emit()
	else:
		direction_change()

func _on_area_entered(area):
	if area.is_in_group("explosion"):
		queue_free()
	elif area.is_in_group("bombs"):
		direction_change()

func direction_change():
	direction = -direction
	var roll = randi_range(0, 99)
	if roll <= direction_change_chance:
		change_direction = true

func _set_random_direction():
	var rand_direction = randi_range(0, 4)
	if rand_direction == 0:
		direction = Vector2(-1, 0)
	elif rand_direction == 1:
		direction = Vector2(1, 0)
	elif rand_direction == 1:
		direction = Vector2(0, -1)
	else:
		direction = Vector2(0, 1)
