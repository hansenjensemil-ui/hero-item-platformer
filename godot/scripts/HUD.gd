extends CanvasLayer

@onready var stats: Label = $Root/Stats
@onready var toast_label: Label = $Root/Toast
@onready var overlay: ColorRect = $Root/Overlay
@onready var overlay_text: Label = $Root/Overlay/Message
@onready var icons: HBoxContainer = $Root/Icons

var toast_life: float = 0.0
var player: Player = null

const ICON_PATHS := {
	"heart": "heartstone",
	"boots": "boots",
	"feather": "feather",
	"blade": "emberblade",
}


func _ready() -> void:
	overlay.visible = false
	toast_label.text = ""
	for k in ["heart", "boots", "feather", "blade"]:
		var tr := TextureRect.new()
		tr.name = k
		tr.texture = Art.png(ICON_PATHS[k])
		tr.custom_minimum_size = Vector2(16, 16)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.modulate = Color(0.25, 0.25, 0.25, 0.85)
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icons.add_child(tr)


func bind(p: Player) -> void:
	player = p
	p.stats_changed.connect(refresh)
	p.relic_collected.connect(_on_relic)
	p.toasted.connect(show_toast)
	refresh()


func refresh() -> void:
	if player == null:
		return
	stats.text = "HP %d/%d    SPD %d    JMP %d    ATK %d" % [
		player.hp, player.max_hp, int(player.speed), int(player.jump), player.atk
	]
	for k in player.has.keys():
		var n := icons.get_node_or_null(String(k))
		if n:
			n.modulate = Color.WHITE if player.has[k] else Color(0.25, 0.25, 0.25, 0.85)


func _on_relic(kind: String, toast: String, color: Color) -> void:
	show_toast(toast, color)
	refresh()
	var n := icons.get_node_or_null(kind)
	if n:
		n.modulate = Color.WHITE


func show_toast(msg: String, color: Color = Color.WHITE) -> void:
	toast_label.text = msg
	toast_label.add_theme_color_override("font_color", color)
	toast_life = 2.4


func show_overlay(msg: String) -> void:
	overlay_text.text = msg
	overlay.visible = true


func hide_overlay() -> void:
	overlay.visible = false


func _process(delta: float) -> void:
	if toast_life > 0.0:
		toast_life -= delta
		toast_label.modulate.a = clampf(toast_life / 0.35, 0.0, 1.0)
		if toast_life <= 0.0:
			toast_label.text = ""
