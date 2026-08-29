extends CharacterBody2D
class_name Enemy

@export var kind: String = "slime"
@export var patrol_min: float = 0.0
@export var patrol_max: float = 0.0

const GRAVITY := 1700.0
const MAX_FALL := 980.0

var hp: int = 2
var hurt: float = 0.0
var home_y: float = 0.0
var alive: bool = true
var walk_speed: float = 55.0
var t: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	add_to_group("enemies")
	home_y = global_position.y
	match kind:
		"slime":
			hp = 2
			walk_speed = 55.0
			sprite.texture = Art.png("slime")
		"bat":
			hp = 1
			walk_speed = 70.0
			sprite.texture = Art.png("bat")
			collision_mask = 0
			motion_mode = MOTION_MODE_FLOATING
		"brute":
			hp = 6
			walk_speed = 40.0
			sprite.texture = Art.png("brute")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if velocity.x == 0.0:
		velocity.x = walk_speed
	t = randf() * TAU


func _physics_process(delta: float) -> void:
	if not alive:
		return
	t += delta
	if hurt > 0.0:
		hurt -= delta
		sprite.modulate = Color(1.0, 0.55, 0.55)
	else:
		sprite.modulate = Color.WHITE

	if kind == "bat":
		if global_position.x < patrol_min:
			global_position.x = patrol_min
			velocity.x = absf(walk_speed)
		elif global_position.x > patrol_max:
			global_position.x = patrol_max
			velocity.x = -absf(walk_speed)
		global_position.x += velocity.x * delta
		global_position.y = home_y + sin(t * 3.0 + global_position.x * 0.01) * 28.0
		sprite.flip_h = velocity.x < 0.0
		return

	velocity.y += GRAVITY * delta
	if velocity.y > MAX_FALL:
		velocity.y = MAX_FALL
	if is_on_floor() and hurt <= 0.0:
		if absf(velocity.x) < 8.0:
			velocity.x = walk_speed * (1.0 if sprite.flip_h == false else -1.0)
	move_and_slide()
	if global_position.x < patrol_min:
		global_position.x = patrol_min
		velocity.x = absf(walk_speed)
	elif global_position.x > patrol_max:
		global_position.x = patrol_max
		velocity.x = -absf(walk_speed)
	if is_on_floor() and randf() < 0.4 * delta:
		velocity.x *= -1.0
	sprite.flip_h = velocity.x < 0.0


func hit(dmg: int, kx: float) -> void:
	if not alive or hurt > 0.0:
		return
	hp -= dmg
	hurt = 0.18
	velocity.x = kx
	velocity.y = -160.0
	if hp <= 0:
		alive = false
		queue_free()


func can_stomp() -> bool:
	return kind != "bat" and kind != "brute"
