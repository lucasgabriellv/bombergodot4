extends Area2D

@export var box_scene: PackedScene
@export var bomb_scene: PackedScene
@export var epicenter_scene: PackedScene
@export var mob_scene: PackedScene

@export var box_count: int
@export var enemy_count: int

var box_positions: Array = [] # TODO: Remove me, all can be handled by box_objects
var box_objects: Dictionary = {}
var bomb_positions: Array = []

func _ready():
	spawn_random_boxes(box_count)
	spawn_random_enemies(enemy_count)
	pass

func _process(delta):
	pass

func spawn_random_boxes(box_count: int):
	var screen_size = get_viewport_rect().size
	var player_pos = get_child(0).position
	var fails = 0
	
	for i in range(box_count):
		if fails > 100:
			break
		
		while true:			
			var ind_x = randi_range(1, (screen_size.x / 32) - 2)
			var ind_y = randi_range(1, (screen_size.y / 32) - 2)
			
			if Vector2(ind_x, ind_y) in box_positions:
				fails += 1
				continue
			
			var pos_x = 32 * ind_x
			var pos_y = 32 * ind_y
			if abs(player_pos.x - pos_x) < 32 and abs(player_pos.y - pos_y) < 32:
				fails += 1
				continue

			var box = box_scene.instantiate()
			box.position = Vector2(pos_x, pos_y)
			box.coords = Vector2(ind_x, ind_y)
			box.connect("box_destroyed", self._on_box_destroyed)
				
			add_child(box)
			box_positions.append(Vector2(ind_x, ind_y))
			box_objects[Vector2(ind_x, ind_y)] = box
			break
		
	box_positions.sort()

func spawn_random_enemies(enemy_count: int):
	var fails = 0
	var screen_size = get_viewport_rect().size
	var player_pos = get_child(0).position
	for i in range(enemy_count):
		if fails > 100:
			break
		
		while true:			
			var ind_x = randi_range(1, (screen_size.x / 32) - 2)
			var ind_y = randi_range(1, (screen_size.y / 32) - 2)
			if Vector2(ind_x, ind_y) in box_positions:
				fails += 1
				continue
			var pos_x = 32 * ind_x
			var pos_y = 32 * ind_y
			if abs(player_pos.x - pos_x) < 32 and abs(player_pos.y - pos_y) < 32:
				fails += 1
				continue
			
			var mob = mob_scene.instantiate()
			mob.position = Vector2(pos_x, pos_y)
			mob._set_random_direction()
			mob.connect("player_hit_by_mob", self._on_player_hit)
			add_child(mob)
			break

func _on_player_bomb_placed():
	var player_pos = get_child(0).position
	var ind_x = (int(player_pos.x) / 32)
	var ind_y = (int(player_pos.y) / 32)
	
	if Vector2(ind_x, ind_y) in bomb_positions:
		return
	
	var bomb = bomb_scene.instantiate()
	bomb.position = Vector2(ind_x * 32 + 16, ind_y * 32 + 16)
	bomb_positions.append(Vector2(ind_x, ind_y))
	
	add_child(bomb)
	bomb.connect("exploded", self._on_bomb_exploded.bind(Vector2(ind_x, ind_y)))

func _on_bomb_exploded(bomb_coords: Vector2):
	bomb_positions.erase(bomb_coords)
	
	# add explosion
	var expl = epicenter_scene.instantiate()
	expl.position = Vector2(bomb_coords.x * 32 + 16, bomb_coords.y * 32 + 16)
	expl.epi_pos = bomb_coords
	var beam_length = 3 # this will get modified by powerups
	var beams = Vector4(0,0,0,0) # -x +x -y +y
	var beams_done = [false, false, false, false] # -x +x -y +y
	var screen_size = get_viewport_rect().size
	
	for i in range(beam_length):
		var tile_minus_x: TileData = $TileMap.get_cell_tile_data(0, bomb_coords + (i + 1) * Vector2(-1, 0))
		if bomb_coords + i * Vector2(-1, 0) in box_positions or (tile_minus_x and tile_minus_x.get_collision_polygons_count(0)):
			beams_done[0] = true
		elif not beams_done[0]:
			beams.x += 1
		var tile_plus_x: TileData = $TileMap.get_cell_tile_data(0, bomb_coords + (i + 1) * Vector2(1, 0))
		if bomb_coords + i * Vector2(1, 0) in box_positions or (tile_plus_x and tile_plus_x.get_collision_polygons_count(0)):
			beams_done[1] = true
		elif not beams_done[1]:
			beams.y += 1
		var tile_minus_y: TileData = $TileMap.get_cell_tile_data(0, bomb_coords + (i + 1) * Vector2(0, -1))
		if bomb_coords + i * Vector2(0, -1) in box_positions or (tile_minus_y and tile_minus_y.get_collision_polygons_count(0)):
			beams_done[2] = true
		elif not beams_done[2]:
			beams.z += 1
		var tile_plus_y: TileData = $TileMap.get_cell_tile_data(0, bomb_coords + (i + 1) * Vector2(0, 1))
		if bomb_coords + i * Vector2(0, 1) in box_positions or (tile_plus_y and tile_plus_y.get_collision_polygons_count(0)):
			beams_done[3] = true
		elif not beams_done[3]:
			beams.w += 1
	expl.beam_length = beams
	expl.connect("player_hit", self._on_player_hit)
	expl.connect("box_hit", self._on_box_hit)
	add_child(expl)

func _on_player_hit():
	var player = get_child(0)
	if not player.dead:
		player.died()
		
func _on_box_hit(pos: Vector2):
	var box = box_objects[pos]
	if box == null:
		print('box hit ERROR')
		return
	
	box.hit()

func _on_box_destroyed(pos: Vector2):
	box_positions.erase(pos)
	box_objects.erase(pos)
