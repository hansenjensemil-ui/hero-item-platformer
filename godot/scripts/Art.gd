extends Node
## Loads sprites from PNG/SVG if present, else from ArtData (in-script PNG bytes).
## Never reads .b64 files — those were truncating on GitHub and crashing the editor.

var _cache := {}


func png(name: String) -> Texture2D:
	if _cache.has(name):
		var cached: Texture2D = _cache[name]
		if cached != null:
			return cached
	var tex := _load_resource("res://assets/%s.png" % name)
	if tex == null:
		tex = _load_resource("res://assets/%s.svg" % name)
	if tex == null:
		tex = _from_data(name)
	if tex == null:
		tex = _placeholder()
	_cache[name] = tex
	return tex


func tex(name: String) -> Texture2D:
	return png(name)


func _load_resource(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var res = load(path)
	if res is Texture2D:
		return res
	return null


func _from_data(name: String) -> Texture2D:
	var b64 := ArtData.b64(name)
	if b64.is_empty():
		push_warning("Art: no data for %s" % name)
		return null
	b64 = b64.strip_edges().replace("\n", "").replace("\r", "").replace(" ", "")
	while b64.length() % 4 != 0:
		b64 += "="
	if b64.length() < 24:
		return null
	var buf: PackedByteArray = Marshalls.base64_to_raw(b64)
	if buf.size() < 24:
		return null
	# PNG magic
	if buf[0] != 0x89 or buf[1] != 0x50:
		return null
	var img := Image.new()
	if img.load_png_from_buffer(buf) != OK:
		push_warning("Art: PNG decode failed for %s" % name)
		return null
	return ImageTexture.create_from_image(img)


func _placeholder() -> Texture2D:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.85, 0.18, 0.32, 1))
	return ImageTexture.create_from_image(img)
