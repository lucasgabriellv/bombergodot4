extends Area2D

@export var beam_length: Vector4

# epi_pos is grid coordinates, not world-space
@export var epi_pos: Vector2

@export var beam_scene: PackedScene
@export var end_scene: PackedScene

signal player_hit
signal box_hit

# Called when the node enters the scene tree for the first time.
func _ready():
	# -x direction
	for i in range(1, beam_length.x + 1):
		if i == beam_length.x: # spawn end
			var end = end_scene.instantiate()
			end.position = i * Vector2(-16, 0) + Vector2(0, 1)
			end.get_child(0).flip_h = true
			end.connect("player_hit", self._on_player_hit)
			end.connect("box_hit", self._on_box_hit.bind(epi_pos + i * Vector2(-1, 0)))
			end.name = "end_" + str(get_child_count())
			add_child(end)
		else: # spawn beam
			var beam = beam_scene.instantiate()
			beam.position = i * Vector2(-16, 0) + Vector2(0, 1)
			beam.connect("player_hit", self._on_player_hit)
			beam.connect("box_hit", self._on_box_hit.bind(epi_pos + i * Vector2(-1, 0)))
			beam.name = "beam_" + str(get_child_count())
			add_child(beam)
			
	# +x direction
	for i in range(1, beam_length.y + 1):
		if i == beam_length.y: # spawn end
			var end = end_scene.instantiate()
			end.position = i * Vector2(16, 0)
			end.connect("player_hit", self._on_player_hit)
			end.connect("box_hit", self._on_box_hit.bind(epi_pos + i * Vector2(1, 0)))
			end.name = "end_" + str(get_child_count())
			add_child(end)
		else: # spawn beam
			var beam = beam_scene.instantiate()
			beam.position = i * Vector2(16, 0)
			beam.connect("player_hit", self._on_player_hit)
			beam.connect("box_hit", self._on_box_hit.bind(epi_pos + i * Vector2(1, 0)))
			beam.name = "beam_" + str(get_child_count())
			add_child(beam)
			
	# -y direction
	for i in range(1, beam_length.z + 1):
		if i == beam_length.z: # spawn end
			var end = end_scene.instantiate()
			end.get_child(0).rotation = 1.5 * PI
			end.position = i * Vector2(0, -16)
			end.connect("player_hit", self._on_player_hit)
			end.connect("box_hit", self._on_box_hit.bind(epi_pos + i * Vector2(0, -1)))
			end.name = "end_" + str(get_child_count())
			add_child(end)
		else: # spawn beam
			var beam = beam_scene.instantiate()
			beam.get_child(0).rotation = 1.5 * PI
			beam.position = i * Vector2(0, -16)
			beam.connect("player_hit", self._on_player_hit)
			beam.connect("box_hit", self._on_box_hit.bind(epi_pos + i * Vector2(0, -1)))
			beam.name = "beam_" + str(get_child_count())
			add_child(beam)
			
	# +y direction
	for i in range(1, beam_length.w + 1):
		if i == beam_length.w: # spawn end
			var end = end_scene.instantiate()
			end.get_child(0).rotation = 0.5 * PI
			end.position = i * Vector2(0, 16)
			end.connect("player_hit", self._on_player_hit)
			end.connect("box_hit", self._on_box_hit.bind(epi_pos + i * Vector2(0, 1)))
			end.name = "end_" + str(get_child_count())
			add_child(end)
		else: # spawn beam
			var beam = beam_scene.instantiate()
			beam.get_child(0).rotation = 0.5 * PI
			beam.position = i * Vector2(0, 16)
			beam.connect("player_hit", self._on_player_hit)
			beam.connect("box_hit", self._on_box_hit.bind(epi_pos + i * Vector2(0, 1)))
			beam.name = "beam_" + str(get_child_count())
			add_child(beam)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	hide()
	# this is not required, keeping it if i need it later
	#$CollisionShape2D.set_deferred("disabled", true)
	#for child in get_children(): # disable the collision objects for children
	# 	if child.name.substr(0, 3) == "end" or child.name.substr(0, 4) == "beam":
	#		child.get_node("CollisionShape2D").set_deferred("disabled", true)
	queue_free()

func _on_box_hit(pos: Vector2):
	box_hit.emit(pos)

func _on_player_hit():
	player_hit.emit()

func _on_body_entered(body: Node2D):
	print(body)
	if body.name == "Player":
		_on_player_hit()
	if body.is_in_group("destructibles"):
		_on_box_hit(epi_pos)
