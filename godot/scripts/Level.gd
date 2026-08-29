extends Node2D

const TILE := 16
const WORLD_W := 6800
const WORLD_H := 640

var player: Player
var checkpoint: Vector2 = Vector2(83, 490)
var state: String = "play"
var brute_msg_cd: float = 0.0

@onready var terrain: TileMapLayer = $Terrain
@onready var platforms: TileMapLayer = $Platforms
@onready var decor: TileMapLayer = $Decor
@onready var world: Node2D = $World
@onready var actors: Node2D = $Actors
@onready var hud = $HUD
@onready var sky: Sprite2D = $ParallaxBackground/SkyLayer/Sky


func _ready() -> void:
	sky.texture = Art.png("sky")
	sky.centered = false
	sky.position = Vector2(0, 0)
	_build_tileset()
	_paint_level()
	_spawn_player()
	_spawn_content()
	hud.bind(player)
	player.died.connect(_on_died)


func _process(delta: float) -> void:
	if brute_msg_cd > 0.0:
		brute_msg_cd -= delta
	if state == "dead":
		if Input.is_physical_key_pressed(KEY_R) or Input.is_physical_key_pressed(KEY_ENTER):
			_respawn()
	elif state == "win":
		if Input.is_physical_key_pressed(KEY_R) or Input.is_physical_key_pressed(KEY_ENTER):
			get_tree().change_scene_to_file("res://scenes/Title.tscn")


func _build_tileset() -> void:
	var tex: Texture2D = Art.png("tiles")
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(TILE, TILE)
	for y in range(4):
		for x in range(8):
			src.create_tile(Vector2i(x, y))
	ts.add_source(src)
	var half := Vector2(TILE / 2.0, TILE / 2.0)
	var full := PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	])
	var top := PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, -half.y + 6.0), Vector2(-half.x, -half.y + 6.0),
	])
	for y in range(4):
		for x in range(8):
			var ac := Vector2i(x, y)
			var td: TileData = src.get_tile_data(ac, 0)
			var solid := (y == 0 and x != 5) or (y == 1 and x in [1, 2])
			var oneway := (x == 5 and y == 0)
			if solid:
				td.add_collision_polygon(0)
				td.set_collision_polygon_points(0, 0, full)
			elif oneway:
				td.add_collision_polygon(0)
				td.set_collision_polygon_points(0, 0, top)
				td.set_collision_polygon_one_way(0, 0, true)
	terrain.tile_set = ts
	platforms.tile_set = ts
	decor.tile_set = ts
	terrain.collision_enabled = true
	platforms.collision_enabled = true
	decor.collision_enabled = false


func _cell(px: float, py: float) -> Vector2i:
	return Vector2i(int(floor(px / float(TILE))), int(floor(py / float(TILE))))


func fill_solid(x: float, y: float, w: float, h: float, kind: String = "dirt") -> void:
	var a0 := Vector2i(0, 0) if kind == "dirt" else Vector2i(4, 0)
	var a1 := Vector2i(1, 0) if kind == "dirt" else Vector2i(3, 0)
	var c0 := _cell(x, y)
	var c1 := _cell(x + w - 0.1, y + h - 0.1)
	for ty in range(c0.y, c1.y + 1):
		for tx in range(c0.x, c1.x + 1):
			var a := a0 if ty == c0.y else a1
			terrain.set_cell(Vector2i(tx, ty), 0, a)


func fill_one_way(x: float, y: float, w: float) -> void:
	var c0 := _cell(x, y)
	var c1 := _cell(x + w - 0.1, y)
	for tx in range(c0.x, c1.x + 1):
		platforms.set_cell(Vector2i(tx, c0.y), 0, Vector2i(5, 0))


func fill_spikes(x: float, y: float, w: float) -> void:
	var c0 := _cell(x, y)
	var c1 := _cell(x + w - 0.1, y)
	for tx in range(c0.x, c1.x + 1):
		decor.set_cell(Vector2i(tx, c0.y), 0, Vector2i(0, 1))
	var hz := preload("res://scenes/Hazard.tscn").instantiate() as Hazard
	hz.position = Vector2(x + w * 0.5, y + 8.0)
	var cs := hz.get_node("CollisionShape2D") as CollisionShape2D
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, 14)
	cs.shape = rect
	world.add_child(hz)


func _paint_level() -> void:
	# Walls and grove
	fill_solid(0, 0, 28, 640, "stone")
	fill_solid(0, 512, 1000, 128, "dirt")
	fill_solid(340, 464, 56, 48, "stone")
	fill_one_way(500, 396, 130)
	# Thorn pit
	fill_spikes(1016, 610, 292)
	fill_one_way(1140, 452, 52)
	# Wind stair / boots
	fill_solid(1320, 512, 760, 128, "dirt")
	fill_one_way(1500, 444, 84)
	fill_one_way(1640, 356, 110)
	fill_one_way(1840, 428, 90)
	fill_one_way(2140, 452, 64)
	fill_spikes(2096, 610, 200)
	fill_solid(2240, 512, 290, 128, "dirt")
	# Skyroot tower
	fill_solid(2500, 360, 40, 280, "stone")
	fill_one_way(2360, 460, 80)
	fill_one_way(2548, 400, 90)
	fill_one_way(2420, 320, 90)
	fill_one_way(2560, 248, 100)
	fill_one_way(2440, 176, 90)
	fill_one_way(2580, 120, 120)
	# Ember court
	fill_solid(2780, 512, 900, 128, "dirt")
	fill_solid(2920, 464, 48, 48, "stone")
	# Speed canyon
	fill_solid(3780, 512, 180, 128, "dirt")
	fill_one_way(4050, 430, 64)
	fill_spikes(3972, 610, 210)
	fill_solid(4190, 496, 140, 144, "dirt")
	fill_spikes(4342, 610, 250)
	fill_one_way(4440, 400, 70)
	fill_solid(4600, 480, 160, 160, "dirt")
	# Brute keep
	fill_solid(4860, 512, 720, 128, "stone")
	fill_solid(4860, 200, 40, 312, "stone")
	fill_spikes(5040, 494, 80)
	fill_spikes(5280, 494, 90)
	fill_spikes(5592, 610, 180)
	fill_solid(5780, 440, 120, 200, "stone")
	fill_one_way(5960, 360, 90)
	fill_one_way(6100, 300, 90)
	# Shrine
	fill_solid(6240, 512, 560, 128, "stone")
	fill_solid(6772, 0, 28, 640, "stone")
	# tufts along grove
	for tx in [8, 18, 28, 90, 200, 310, 400]:
		decor.set_cell(Vector2i(tx, 31), 0, Vector2i(3, 1))


func _spawn_player() -> void:
	player = preload("res://scenes/Player.tscn").instantiate() as Player
	player.position = Vector2(83, 512)
	checkpoint = player.position
	actors.add_child(player)
	player.cam.limit_left = 0
	player.cam.limit_top = 0
	player.cam.limit_right = WORLD_W
	player.cam.limit_bottom = WORLD_H
	player.cam.make_current()


func _spawn_content() -> void:
	_relic("heart", 554, 360)
	_relic("boots", 1680, 318)
	_relic("feather", 2620, 82)
	_relic("blade", 3100, 472)

	_enemy("slime", 760, 512, 620, 940)
	_enemy("slime", 1480, 512, 1360, 1680)
	_enemy("bat", 1720, 250, 1600, 1880)
	_enemy("bat", 2480, 200, 2360, 2680)
	_enemy("slime", 3000, 512, 2860, 3180)
	_enemy("slime", 3340, 512, 3220, 3520)
	_enemy("bat", 4080, 300, 3980, 4300)
	_enemy("bat", 4480, 280, 4360, 4680)
	_enemy("slime", 5000, 512, 4920, 5120)
	_enemy("brute", 5160, 512, 4940, 5460)
	_enemy("brute", 5400, 512, 5200, 5540)

	_deco("tree", 180, 512)
	_deco("tree", 860, 512)
	_deco("bush", 420, 512)
	_deco("lantern", 1900, 512)
	_deco("tree", 6360, 512)
	_deco("banner", 6480, 512)
	_deco("lantern", 6420, 512)

	_sign(120, 430, "Arrows / AD to run")
	_sign(280, 430, "Space to jump  •  J/K/X attack")
	_sign(2330, 470, "The feather waits above")
	_sign(3520, 430, "Checkpoint")
	_sign(4880, 430, "Brute Keep — bring the blade")
	_sign(6300, 430, "The shrine")

	var cp := preload("res://scenes/Checkpoint.tscn").instantiate() as Checkpoint
	cp.position = Vector2(3560, 500)
	var cs := cp.get_node("CollisionShape2D") as CollisionShape2D
	var r := RectangleShape2D.new()
	r.size = Vector2(36, 112)
	cs.shape = r
	cs.position = Vector2(0, -56)
	world.add_child(cp)
	cp.activated.connect(_on_checkpoint)
	var ember := Sprite2D.new()
	ember.texture = Art.png("lantern")
	ember.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ember.position = Vector2(0, -40)
	cp.add_child(ember)

	var goal := preload("res://scenes/Goal.tscn").instantiate() as Goal
	goal.position = Vector2(6480, 456)
	var gs := goal.get_node("CollisionShape2D") as CollisionShape2D
	var gr := RectangleShape2D.new()
	gr.size = Vector2(40, 112)
	gs.shape = gr
	world.add_child(goal)
	goal.reached.connect(_on_win)


func _relic(kind: String, x: float, y: float) -> void:
	var r := preload("res://scenes/Relic.tscn").instantiate() as Relic
	r.kind = kind
	r.position = Vector2(x, y)
	actors.add_child(r)


func _enemy(kind: String, x: float, y: float, min_x: float, max_x: float) -> void:
	var path := "res://scenes/Enemy.tscn"
	match kind:
		"slime":
			path = "res://scenes/Slime.tscn"
		"bat":
			path = "res://scenes/Bat.tscn"
		"brute":
			path = "res://scenes/Brute.tscn"
	var e: Enemy = load(path).instantiate()
	e.kind = kind
	e.position = Vector2(x, y)
	e.patrol_min = min_x
	e.patrol_max = max_x
	actors.add_child(e)


func _deco(kind: String, x: float, ground_y: float) -> void:
	var s := Sprite2D.new()
	s.texture = Art.png(kind)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.centered = true
	var tex_h := s.texture.get_height() if s.texture else 16
	s.position = Vector2(x, ground_y - float(tex_h) * 0.5)
	world.add_child(s)


func _sign(x: float, y: float, text: String) -> void:
	var l := Label.new()
	l.text = text
	l.position = Vector2(x, y)
	l.add_theme_font_size_override("font_size", 8)
	l.add_theme_color_override("font_color", Color(0.95, 0.88, 0.70))
	l.add_theme_color_override("font_shadow_color", Color(0.08, 0.05, 0.06, 0.8))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	world.add_child(l)


func _on_checkpoint(pos: Vector2) -> void:
	checkpoint = Vector2(pos.x, 512)


func _on_died() -> void:
	state = "dead"
	hud.show_overlay("Fallen.\nR or Enter to rise at the last checkpoint.\nRelics are kept.")


func _respawn() -> void:
	state = "play"
	hud.hide_overlay()
	player.respawn_at(checkpoint)


func _on_win() -> void:
	if state == "win":
		return
	state = "play"
	player.frozen = true
	state = "win"
	hud.show_overlay("The shrine accepts you.\nEmbervale's relics are yours.\nR or Enter to return to title.")
