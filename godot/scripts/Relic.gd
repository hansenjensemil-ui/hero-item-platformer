extends Area2D
class_name Relic

const INFO := {
	"heart": {
		"name": "Heartstone",
		"toast": "Heartstone! +4 Max HP, fully healed.",
		"tex": "heartstone",
		"color": Color(0.90, 0.22, 0.27),
	},
	"boots": {
		"name": "Windstep Boots",
		"toast": "Windstep Boots! You run faster.",
		"tex": "boots",
		"color": Color(0.30, 0.79, 0.94),
	},
	"feather": {
		"name": "Skyroot Feather",
		"toast": "Skyroot Feather! Jump soars higher.",
		"tex": "feather",
		"color": Color(0.96, 0.89, 0.52),
	},
	"blade": {
		"name": "Emberblade",
		"toast": "Emberblade! Hits hit much harder.",
		"tex": "emberblade",
		"color": Color(1.0, 0.62, 0.11),
	},
}

@export var kind: String = "heart"

var taken: bool = false
var base_y: float = 0.0
var t: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	monitoring = true
	monitorable = true
	base_y = position.y
	t = randf() * TAU
	if INFO.has(kind):
		sprite.texture = Art.png(String(INFO[kind]["tex"]))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if taken:
		return
	t += delta
	position.y = base_y + sin(t * 3.0) * 3.0
	var pulse := 0.75 + 0.25 * sin(t * 5.0)
	modulate = Color(pulse, pulse, pulse, 1.0)


func _on_body_entered(body: Node) -> void:
	if taken:
		return
	if body is Player:
		taken = true
		(body as Player).apply_relic(kind)
		visible = false
		set_deferred("monitoring", false)
