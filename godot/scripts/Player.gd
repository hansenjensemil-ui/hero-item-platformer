extends CharacterBody2D
class_name Player

signal stats_changed
signal relic_collected(kind: String, toast: String, color: Color)
signal died
signal toasted(msg: String, color: Color)

const GRAVITY := 1700.0
const MAX_FALL := 980.0
const ACCEL := 2600.0
const FRICTION := 2200.0
const AIR_FRIC := 480.0
const COYOTE := 0.09
const BUFFER := 0.12
const BASE_SPEED := 220.0
const BASE_JUMP := 700.0
const BASE_HP := 6
const BASE_ATK := 1

var facing: int = 1
var coyote: float = 0.0
var buffer: float = 0.0
var jump_held: bool = false
var hp: int = BASE_HP
var max_hp: int = BASE_HP
var speed: float = BASE_SPEED
var jump: float = BASE_JUMP
var atk: int = BASE_ATK
var invuln: float = 0.0
var atk_t: float = 0.0
var atk_cd: float = 0.0
var has := {"heart": false, "boots": false, "feather": false, "blade": false}
var frozen: bool = false
var anim_t: float = 0.0
var brute_toast_cd: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hit_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var slash: Sprite2D = $Slash
@onready var cam: Camera2D = $Camera2D
@onready var hurtbox: Area2D = $Hurtbox


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	add_to_group("player")
	sprite.texture = Art.png("hero")
	slash.texture = Art.png("slash")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slash.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slash.visible = false
	hitbox.monitoring = true
	hitbox.collision_layer = 8
	hitbox.collision_mask = 4
	floor_snap_length = 4.0
	safe_margin = 0.08


func _physics_process(delta: float) -> void:
	anim_t += delta
	if frozen:
		velocity = Vector2.ZERO
		slash.visible = false
		return

	if brute_toast_cd > 0.0:
		brute_toast_cd -= delta
	if invuln > 0.0:
		invuln -= delta
		sprite.modulate.a = 0.45 if int(invuln * 18.0) % 2 == 0 else 1.0
	else:
		sprite.modulate.a = 1.0

	if atk_t > 0.0:
		atk_t -= delta
		if atk_t <= 0.0:
			hitbox.monitoring = false
			slash.visible = false
	if atk_cd > 0.0:
		atk_cd -= delta

	var dir := 0
	if _want_right():
		dir += 1
	if _want_left():
		dir -= 1
	if dir != 0:
		facing = dir
		sprite.flip_h = facing < 0

	var acc := ACCEL if is_on_floor() else ACCEL * 0.7
	if dir != 0:
		velocity.x += float(dir) * acc * delta
	else:
		var fr := (FRICTION if is_on_floor() else AIR_FRIC) * delta
		if absf(velocity.x) <= fr:
			velocity.x = 0.0
		else:
			velocity.x -= signf(velocity.x) * fr
	velocity.x = clampf(velocity.x, -speed, speed)

	velocity.y += GRAVITY * delta
	if velocity.y > MAX_FALL:
		velocity.y = MAX_FALL

	if is_on_floor():
		coyote = COYOTE
	else:
		coyote -= delta

	if _want_jump():
		buffer = BUFFER
		if not jump_held and coyote > 0.0:
			_do_jump()
	else:
		if jump_held and velocity.y < 0.0:
			velocity.y *= 0.45
		jump_held = false
		buffer -= delta

	if buffer > 0.0 and coyote > 0.0 and not jump_held:
		_do_jump()

	if _want_atk() and atk_cd <= 0.0:
		atk_t = 0.18
		atk_cd = 0.36
		hitbox.monitoring = true
		slash.visible = true

	hit_shape.position.x = 16.0 * float(facing)
	slash.position = Vector2(18.0 * float(facing), -14.0)
	slash.flip_h = facing < 0
	slash.rotation_degrees = -20.0 if facing > 0 else 20.0

	move_and_slide()
	_combat()

	if global_position.y > 700.0:
		take_damage(99, 0.0)


func _do_jump() -> void:
	velocity.y = -jump
	coyote = 0.0
	buffer = 0.0
	jump_held = true


func _combat() -> void:
	if atk_t > 0.0:
		for body in hitbox.get_overlapping_bodies():
			if body is Enemy and (body as Enemy).alive:
				(body as Enemy).hit(atk, float(facing) * 220.0)

	for body in hurtbox.get_overlapping_bodies():
		var e := body as Enemy
		if e == null or not e.alive:
			continue
		var stomp := velocity.y > 60.0 and global_position.y <= e.global_position.y + 4.0
		if stomp and e.can_stomp():
			e.hit(maxi(1, atk), float(facing) * 80.0)
			velocity.y = -jump * 0.55
			invuln = maxf(invuln, 0.12)
		elif stomp and e.kind == "brute":
			velocity.y = -jump * 0.4
			invuln = maxf(invuln, 0.08)
			if (not has["blade"]) and brute_toast_cd <= 0.0:
				brute_toast_cd = 2.2
				toasted.emit("The brute's hide needs the Emberblade.", Color(0.85, 0.55, 0.35))
		else:
			take_damage(2 if e.kind == "brute" else 1, -float(facing) * 180.0)


func take_damage(dmg: int, kx: float) -> void:
	if invuln > 0.0 or frozen:
		return
	hp -= dmg
	invuln = 1.05
	velocity.x = kx
	velocity.y = -240.0
	stats_changed.emit()
	if hp <= 0:
		hp = 0
		frozen = true
		died.emit()


func apply_relic(kind: String) -> void:
	if has.get(kind, false):
		return
	has[kind] = true
	match kind:
		"heart":
			max_hp += 4
			hp = max_hp
		"boots":
			speed = BASE_SPEED + 100.0
		"feather":
			jump = BASE_JUMP + 160.0
		"blade":
			atk = 3
	var info: Dictionary = Relic.INFO[kind]
	relic_collected.emit(kind, String(info["toast"]), info["color"])
	stats_changed.emit()


func respawn_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	hp = max_hp
	invuln = 1.1
	frozen = false
	atk_t = 0.0
	slash.visible = false
	stats_changed.emit()


func _want_left() -> bool:
	return Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)


func _want_right() -> bool:
	return Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)


func _want_jump() -> bool:
	return (
		Input.is_physical_key_pressed(KEY_SPACE)
		or Input.is_physical_key_pressed(KEY_W)
		or Input.is_physical_key_pressed(KEY_UP)
	)


func _want_atk() -> bool:
	return (
		Input.is_physical_key_pressed(KEY_J)
		or Input.is_physical_key_pressed(KEY_K)
		or Input.is_physical_key_pressed(KEY_X)
	)
