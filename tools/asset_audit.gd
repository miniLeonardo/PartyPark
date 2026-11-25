extends Node
## Prüfskript Asset-Budget (WP 5.3): baut jedes Minispiel über die Sandbox auf und zählt je Arena
## Dreiecke, Meshes, MultiMesh-Instanzen, Materialien, Lichter, schätzt Draw Calls und listet alle
## genutzten Texturen mit Größe, Format, Mipmaps und geschätztem Grafikspeicher (VRAM).
## Danach Überblick über `assets/third_party/` (Dateien, MB je Paket, größte Dateien, Lizenzdatei,
## Importvorgaben der Texturen).
## Start (headless genügt):  godot --headless --path . -- --tool-asset_audit [--write]
## Mit --write wird die Tabelle in docs/PERFORMANCE.md zwischen den Markierungen ersetzt.
## Budgets stehen in docs/ART_GUIDE.md (Abschnitt „Asset-Budget und Importvorgaben“); Überschreitungen sind mit ⚠ markiert.

# Budget je Minispiel-Arena (gemessen 2026-11-25: höchstens 152k Dreiecke, 220 Draw Calls ohne Wackelwaben, 0,2 MB Texturen)
const BUDGET_TRIANGLES: int = 200000
const BUDGET_DRAW_CALLS: int = 400
const BUDGET_LIGHTS: int = 10
const BUDGET_TEXTURE_MB: float = 8.0
# Budget für den Park (Hub): ganze Szene gezählt, nicht nur das Bild (gemessen 347k Dreiecke, ~1360 Draw Calls, 18 Lichter)
const BUDGET_HUB_TRIANGLES: int = 450000
const BUDGET_HUB_DRAW_CALLS: int = 1600
const BUDGET_HUB_LIGHTS: int = 24
const BUDGET_HUB_TEXTURE_MB: float = 16.0
# Je Textur: größte Kantenlänge in Pixeln
const BUDGET_TEXTURE: int = 1024
# Fremd-Assets: Warnung ab dieser Dateigröße (Git-LFS-Schwelle, siehe ART_GUIDE)
const BUDGET_FILE_MB: float = 10.0
const THIRD_PARTY_DIR: String = "res://assets/third_party"
const LARGEST_FILES_SHOWN: int = 8
# Importvorgaben für Texturen in 3D (siehe ART_GUIDE): VRAM-komprimiert, mit Mipmaps
const IMPORT_COMPRESS_MODE_VRAM: int = 2
const MARK_BEGIN: String = "<!-- asset_audit:begin -->"
const MARK_END: String = "<!-- asset_audit:end -->"

const FORMAT_NAMES: Dictionary = {
	Image.FORMAT_L8: "L8", Image.FORMAT_LA8: "LA8", Image.FORMAT_R8: "R8", Image.FORMAT_RG8: "RG8",
	Image.FORMAT_RGB8: "RGB8", Image.FORMAT_RGBA8: "RGBA8", Image.FORMAT_RGBAH: "RGBAH", Image.FORMAT_RGBAF: "RGBAF",
	Image.FORMAT_DXT1: "DXT1 (BC1)", Image.FORMAT_DXT3: "DXT3 (BC2)", Image.FORMAT_DXT5: "DXT5 (BC3)",
	Image.FORMAT_RGTC_R: "BC4", Image.FORMAT_RGTC_RG: "BC5", Image.FORMAT_BPTC_RGBA: "BPTC (BC7)",
	Image.FORMAT_ETC2_RGB8: "ETC2 RGB", Image.FORMAT_ETC2_RGBA8: "ETC2 RGBA", Image.FORMAT_ASTC_4x4: "ASTC 4x4",
}

var _rows: Array[Dictionary] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _run() -> void:
	var host: Node = get_tree().current_scene
	if host:
		host.queue_free()
	await get_tree().process_frame
	var sandbox := MinigameSandbox.new()
	add_child(sandbox)
	for info: MinigameInfo in MinigameRegistry.infos:
		sandbox.start(info, info.formats[0], 1, 9999.0, 1234)
		await get_tree().process_frame
		await get_tree().process_frame
		var row: Dictionary = audit(sandbox.minigame)
		row["name"] = info.display_name
		row["id"] = String(info.id)
		row["hub"] = false
		_rows.append(row)
		_print_row(row)
		sandbox.stop()
		await get_tree().process_frame
	if ResourceLoader.exists("res://modes/hub/hub.tscn"):
		var hub_packed: PackedScene = load("res://modes/hub/hub.tscn")
		var hub_inst: Node = hub_packed.instantiate()
		add_child(hub_inst)
		await get_tree().process_frame
		await get_tree().process_frame
		var hub_row: Dictionary = audit(hub_inst)
		hub_row["name"] = "Freizeitpark (Hub)"
		hub_row["id"] = "hub"
		hub_row["hub"] = true
		_rows.append(hub_row)
		_print_row(hub_row)
		hub_inst.queue_free()
		await get_tree().process_frame
	var table: String = make_table(_rows)
	print(table)
	print("")
	print(third_party_overview(THIRD_PARTY_DIR))
	if OS.get_cmdline_user_args().has("--write"):
		_write_doc(table)
	get_tree().quit(0)


func _print_row(row: Dictionary) -> void:
	print("AUDIT %-16s Dreiecke %7d  Meshes %4d  MultiMesh-Instanzen %5d  Materialien %3d  Draw Calls ~%4d  Texturen %d (%.2f MB VRAM, max %d px)  Lichter %d" % [
		row["id"], row["triangles"], row["meshes"], row["mm_instances"], row["materials"], row["draw_calls"],
		(row["textures"] as Array).size(), _mb(int(row["texture_bytes"])), row["max_texture"], row["lights"]])
	for tex: Dictionary in row["textures"]:
		var warn: String = " ⚠ über %d px" % BUDGET_TEXTURE if maxi(int(tex["width"]), int(tex["height"])) > BUDGET_TEXTURE else ""
		if not bool(tex["mipmaps"]):
			warn += " ⚠ ohne Mipmaps"
		print("      TEX %-62s %4dx%-4d  %-11s  Mipmaps %-4s  %.2f MB%s" % [
			tex["path"], tex["width"], tex["height"], tex["format"], "ja" if tex["mipmaps"] else "nein", _mb(int(tex["bytes"])), warn])


## Zählt alles Sichtbare unter `root`. Draw Calls grob: je sichtbarer Oberfläche ein Aufruf für die Farbe
## plus einer für den Schatten, wenn die Oberfläche Schatten wirft; MultiMesh zählt wie eine Oberfläche.
## Texturen: alle Texturen der genutzten Materialien (jede Datei bzw. Instanz einmal), VRAM aus den echten Bilddaten.
static func audit(root: Node) -> Dictionary:
	var triangles: int = 0
	var meshes: int = 0
	var mm_instances: int = 0
	var draw_calls: int = 0
	var materials: Dictionary = {}
	var textures: Dictionary = {}
	var lights: int = 0
	var shadow_lights: int = 0
	for node: Node in root.find_children("*", "", true, false):
		if node is Light3D:
			lights += 1
			if (node as Light3D).shadow_enabled:
				shadow_lights += 1
		if not (node is GeometryInstance3D) or not (node as Node3D).is_visible_in_tree():
			continue
		var geo := node as GeometryInstance3D
		if geo.material_overlay:
			_collect_textures(geo.material_overlay, textures)
		if node is SpriteBase3D and node.get("texture") is Texture2D:
			_add_texture(node.get("texture") as Texture2D, textures)
		var casts: bool = geo.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var mesh: Mesh = null
		var count: int = 1
		if node is MeshInstance3D:
			mesh = (node as MeshInstance3D).mesh
			meshes += 1
		elif node is MultiMeshInstance3D and (node as MultiMeshInstance3D).multimesh:
			var mm: MultiMesh = (node as MultiMeshInstance3D).multimesh
			mesh = mm.mesh
			count = mm.visible_instance_count if mm.visible_instance_count >= 0 else mm.instance_count
			mm_instances += count
		if mesh == null:
			continue
		for s: int in mesh.get_surface_count():
			triangles += _surface_triangles(mesh, s) * count
			draw_calls += 2 if casts else 1
			var material: Material = geo.material_override
			if material == null:
				if node is MeshInstance3D:
					material = (node as MeshInstance3D).get_active_material(s)
				else:
					material = mesh.surface_get_material(s)
			if material:
				materials[material.get_instance_id()] = true
				_collect_textures(material, textures)
				if material.next_pass:
					draw_calls += 1
	var texture_list: Array[Dictionary] = []
	var texture_bytes: int = 0
	var max_texture: int = 0
	for info: Dictionary in textures.values():
		texture_list.append(info)
		texture_bytes += int(info["bytes"])
		max_texture = maxi(max_texture, maxi(int(info["width"]), int(info["height"])))
	texture_list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["bytes"]) > int(b["bytes"]))
	return {"triangles": triangles, "meshes": meshes, "mm_instances": mm_instances, "materials": materials.size(),
		"draw_calls": draw_calls, "max_texture": max_texture, "lights": lights, "shadow_lights": shadow_lights,
		"textures": texture_list, "texture_bytes": texture_bytes}


static func _surface_triangles(mesh: Mesh, surface: int) -> int:
	if mesh is PrimitiveMesh or mesh is ArrayMesh:
		var arrays: Array = mesh.surface_get_arrays(surface)
		var indices: Variant = arrays[Mesh.ARRAY_INDEX]
		if indices != null and (indices as PackedInt32Array).size() > 0:
			return (indices as PackedInt32Array).size() / 3
		return (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return 0


## Sammelt alle Texturen eines Materials (alle Kanäle von BaseMaterial3D, Shader-Parameter, next_pass).
static func _collect_textures(material: Material, out: Dictionary) -> void:
	if material is BaseMaterial3D:
		var base := material as BaseMaterial3D
		for param: int in BaseMaterial3D.TEXTURE_MAX:
			var tex: Texture2D = base.get_texture(param as BaseMaterial3D.TextureParam)
			if tex:
				_add_texture(tex, out)
	elif material is ShaderMaterial:
		var shader_material := material as ShaderMaterial
		if shader_material.shader:
			for uniform: Dictionary in shader_material.shader.get_shader_uniform_list():
				var value: Variant = shader_material.get_shader_parameter(uniform["name"])
				if value is Texture2D:
					_add_texture(value as Texture2D, out)
	if material.next_pass:
		_collect_textures(material.next_pass, out)


## Trägt eine Textur mit Größe, Format, Mipmaps und VRAM-Schätzung ein (jede Instanz nur einmal).
static func _add_texture(tex: Texture2D, out: Dictionary) -> void:
	var key: int = tex.get_instance_id()
	if out.has(key):
		return
	var path: String = tex.resource_path if tex.resource_path != "" and not tex.resource_path.contains("::") else "(%s im Code)" % tex.get_class()
	var info: Dictionary = {"path": path, "width": tex.get_width(), "height": tex.get_height(), "format": "?", "mipmaps": false, "bytes": 0}
	var image: Image = null
	if not (tex is ViewportTexture):
		image = tex.get_image()
	if image:
		info["format"] = FORMAT_NAMES.get(image.get_format(), "Format %d" % image.get_format())
		info["mipmaps"] = image.has_mipmaps()
		info["bytes"] = image.get_data_size()
	else:
		# Ohne Bilddaten (z. B. Viewport) grob als RGBA8 ohne Mipmaps schätzen
		info["bytes"] = tex.get_width() * tex.get_height() * 4
	out[key] = info


static func _mb(bytes: int) -> float:
	return float(bytes) / 1048576.0


static func make_table(rows: Array[Dictionary]) -> String:
	var lines: PackedStringArray = []
	lines.append("Stand %s, erzeugt mit `tools/asset_audit.gd` (Grafikstufe Mittel, ohne Kulissen-Kürzung im Splitscreen)." % Time.get_date_string_from_system())
	lines.append("")
	lines.append("| Minispiel | Dreiecke | Meshes | MultiMesh-Instanzen | Materialien | Draw Calls (geschätzt) | Texturen (VRAM MB) | Textur max px | Lichter (mit Schatten) |")
	lines.append("|---|---|---|---|---|---|---|---|---|")
	for r: Dictionary in rows:
		var hub: bool = bool(r.get("hub", false))
		var tri_budget: int = BUDGET_HUB_TRIANGLES if hub else BUDGET_TRIANGLES
		var dc_budget: int = BUDGET_HUB_DRAW_CALLS if hub else BUDGET_DRAW_CALLS
		var light_budget: int = BUDGET_HUB_LIGHTS if hub else BUDGET_LIGHTS
		var mb_budget: float = BUDGET_HUB_TEXTURE_MB if hub else BUDGET_TEXTURE_MB
		var mb: float = _mb(int(r["texture_bytes"]))
		var tri: String = "%d%s" % [r["triangles"], " ⚠" if int(r["triangles"]) > tri_budget else ""]
		var dc: String = "%d%s" % [r["draw_calls"], " ⚠" if int(r["draw_calls"]) > dc_budget else ""]
		var tex_mb: String = "%d (%.2f)%s" % [(r["textures"] as Array).size(), mb, " ⚠" if mb > mb_budget else ""]
		var tex: String = "%d%s" % [r["max_texture"], " ⚠" if int(r["max_texture"]) > BUDGET_TEXTURE else ""]
		var light: String = "%d (%d)%s" % [r["lights"], r["shadow_lights"], " ⚠" if int(r["lights"]) > light_budget or int(r["shadow_lights"]) > 1 else ""]
		lines.append("| %s | %s | %d | %d | %d | %s | %s | %s | %s |" % [r["name"], tri, r["meshes"], r["mm_instances"], r["materials"], dc, tex_mb, tex, light])
	return "\n".join(lines)


## Überblick über die Fremd-Assets: je Paket Dateien, Größe, Lizenzdatei und Texturen mit abweichenden
## Importvorgaben; danach die größten Dateien. `.import`-Dateien zählen nicht mit.
static func third_party_overview(root_dir: String) -> String:
	var lines: PackedStringArray = []
	lines.append("Fremd-Assets in %s:" % root_dir)
	lines.append("")
	lines.append("| Paket | Dateien | MB | Lizenzdatei | Texturen | Importvorgaben |")
	lines.append("|---|---|---|---|---|---|")
	var all_files: Array[Dictionary] = []
	var total_bytes: int = 0
	var total_files: int = 0
	var dir := DirAccess.open(root_dir)
	if dir == null:
		return "AUDIT: %s nicht gefunden" % root_dir
	for package: String in dir.get_directories():
		var files: Array[Dictionary] = []
		_list_files(root_dir.path_join(package), files)
		var bytes: int = 0
		var has_license: bool = false
		var textures: int = 0
		var import_issues: PackedStringArray = []
		for f: Dictionary in files:
			bytes += int(f["bytes"])
			var file_name: String = String(f["path"]).get_file().to_lower()
			if file_name.begins_with("license") or file_name.begins_with("licence"):
				has_license = true
			if String(f["path"]).get_extension().to_lower() in ["png", "jpg", "jpeg", "webp", "tga", "bmp", "exr", "hdr"]:
				textures += 1
				var issue: String = _texture_import_issue(String(f["path"]))
				if issue != "":
					import_issues.append("%s: %s" % [String(f["path"]).get_file(), issue])
		all_files.append_array(files)
		total_bytes += bytes
		total_files += files.size()
		lines.append("| %s | %d | %.2f | %s | %d | %s |" % [package, files.size(), _mb(bytes), "ja" if has_license else "⚠ fehlt",
			textures, "ok" if import_issues.is_empty() else "⚠ " + ", ".join(import_issues)])
	lines.append("| **Summe** | %d | %.2f | | | |" % [total_files, _mb(total_bytes)])
	lines.append("")
	all_files.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["bytes"]) > int(b["bytes"]))
	lines.append("Größte Dateien:")
	for i: int in mini(LARGEST_FILES_SHOWN, all_files.size()):
		var f: Dictionary = all_files[i]
		var warn: String = " ⚠ über %.0f MB" % BUDGET_FILE_MB if _mb(int(f["bytes"])) > BUDGET_FILE_MB else ""
		lines.append("  %.2f MB  %s%s" % [_mb(int(f["bytes"])), String(f["path"]).trim_prefix(root_dir + "/"), warn])
	return "\n".join(lines)


static func _list_files(path: String, out: Array[Dictionary]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for file_name: String in dir.get_files():
		if file_name.ends_with(".import") or file_name.ends_with(".uid"):
			continue
		var full: String = path.path_join(file_name)
		var file := FileAccess.open(full, FileAccess.READ)
		var bytes: int = file.get_length() if file else 0
		out.append({"path": full, "bytes": bytes})
	for sub: String in dir.get_directories():
		_list_files(path.path_join(sub), out)


## Prüft die `.import`-Datei einer Textur gegen die Vorgaben (VRAM-komprimiert, Mipmaps an). Leer = in Ordnung.
static func _texture_import_issue(path: String) -> String:
	var config := ConfigFile.new()
	if config.load(path + ".import") != OK:
		return "keine .import-Datei"
	var issues: PackedStringArray = []
	if int(config.get_value("params", "compress/mode", -1)) != IMPORT_COMPRESS_MODE_VRAM:
		issues.append("nicht VRAM-komprimiert")
	if not bool(config.get_value("params", "mipmaps/generate", false)):
		issues.append("ohne Mipmaps")
	return " und ".join(issues)


func _write_doc(table: String) -> void:
	var path: String = "res://docs/PERFORMANCE.md"
	var text: String = FileAccess.get_file_as_string(path)
	var begin: int = text.find(MARK_BEGIN)
	var end: int = text.find(MARK_END)
	if begin < 0 or end < 0:
		print("AUDIT: Markierungen in docs/PERFORMANCE.md fehlen, nichts geschrieben")
		return
	var updated: String = text.substr(0, begin + MARK_BEGIN.length()) + "\n" + table + "\n" + text.substr(end)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(updated)
	file.close()
	print("AUDIT: docs/PERFORMANCE.md aktualisiert")
