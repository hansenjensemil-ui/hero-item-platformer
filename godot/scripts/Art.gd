extends Node
## Loads sprites from ArtData (in-script PNG). Never reads .b64 files.
## Does not load SVG sprites — pixel-rect SVGs crash Godot's importer on project open.

var _cache := {}


func png(name: String) -> Texture2D:
	if _cache.has(name):
		var cached: Texture2D = _cache[name]
		if cached != null:
			return cached
	var tex := _from_data(name)
	if tex == null and name == "sky":
		tex = _sky()
	if tex == null:
		tex = _placeholder()
	_cache[name] = tex
	return tex


func tex(name: String) -> Texture2D:
	return png(name)


func _from_data(name: String) -> Texture2D:
	var b64 := ArtData.b64(name)
	if b64.is_empty():
		b64 = ArtDataRelics.b64(name)
	if b64.is_empty():
		return null
	b64 = b64.strip_edges().replace("\n", "").replace("\r", "").replace(" ", "")
	while b64.length() % 4 != 0:
		b64 += "="
	if b64.length() < 24:
		return null
	var buf: PackedByteArray = Marshalls.base64_to_raw(b64)
	if buf.size() < 24:
		return null
	if buf[0] != 0x89 or buf[1] != 0x50:
		return null
	var img := Image.new()
	if img.load_png_from_buffer(buf) != OK:
		push_warning("Art: PNG decode failed for %s" % name)
		return null
	return ImageTexture.create_from_image(img)


func _sky() -> Texture2D:
	var img := Image.create(640, 160, false, Image.FORMAT_RGBA8)
	for y in range(160):
		var t := float(y) / 159.0
		var c: Color
		if t < 0.35:
			c = Color(0.286, 0.239, 0.325).lerp(Color(0.478, 0.314, 0.376), t / 0.35)
		elif t < 0.70:
			c = Color(0.478, 0.314, 0.376).lerp(Color(0.753, 0.475, 0.369), (t - 0.35) / 0.35)
		else:
			c = Color(0.753, 0.475, 0.369).lerp(Color(0.910, 0.627, 0.361), (t - 0.70) / 0.30)
		for x in range(640):
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


func _placeholder() -> Texture2D:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.85, 0.18, 0.32, 1))
	return ImageTexture.create_from_image(img)
