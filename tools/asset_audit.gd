extends Node
## Prüfskript Asset-Budget (WP 5.3): baut jedes Minispiel über die Sandbox auf und zählt je Arena
## Dreiecke, Meshes, MultiMesh-Instanzen, Materialien, Texturgrößen, Lichter und schätzt Draw Calls.
## Start (headless genügt):  godot --headless --path . -- --tool-asset_audit [--write]
## Mit --write wird die Tabelle in docs/PERFORMANCE.md zwischen den Markierungen ersetzt.
## Budgets stehen in docs/ART_GUIDE.md (Abschnitt Leistung); Überschreitungen sind mit ⚠ markiert.

const BUDGET_TRIANGLES: int = 300000
const BUDGET_DRAW_CALLS: int = 400
const BUDGET_TEXTURE: int = 1024
const MARK_BEGIN: String = "<!-- asset_audit:begin -->"
const MARK_END: String = "<!-- asset_audit:end -->"

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
		_rows.append(row)
		print("AUDIT %-16s Dreiecke %7d  Meshes %4d  MultiMesh-Instanzen %5d  Materialien %3d  Draw Calls ~%4d  Textur max %4d  Lichter %d" % [
			row["id"], row["triangles"], row["meshes"], row["mm_instances"], row["materials"], row["draw_calls"], row["max_texture"], row["lights"]])
		sandbox.stop()
		await get_tree().process_frame
	var table: String = make_table(_rows)
	print(table)
	if OS.get_cmdline_user_args().has("--write"):
		_write_doc(table)
	get_tree().quit(0)


## Zählt alles Sichtbare unter `root`. Draw Calls grob: je sichtbarer Oberfläche ein Aufruf für die Farbe
## plus einer für den Schatten, wenn die Oberfläche Schatten wirft; MultiMesh zählt wie eine Oberfläche.
static func audit(root: Node) -> Dictionary:
	var triangles: int = 0
	var meshes: int = 0
	var mm_instances: int = 0
	var draw_calls: int = 0
	var materials: Dictionary = {}
	var max_texture: int = 0
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
			if material == null and node is MeshInstance3D:
				material = (node as MeshInstance3D).get_active_material(s)
			if material:
				materials[material.get_instance_id()] = true
				max_texture = maxi(max_texture, _material_texture_size(material))
				if material.next_pass:
					draw_calls += 1
	return {"triangles": triangles, "meshes": meshes, "mm_instances": mm_instances, "materials": materials.size(),
		"draw_calls": draw_calls, "max_texture": max_texture, "lights": lights, "shadow_lights": shadow_lights}


static func _surface_triangles(mesh: Mesh, surface: int) -> int:
	if mesh is PrimitiveMesh or mesh is ArrayMesh:
		var arrays: Array = mesh.surface_get_arrays(surface)
		var indices: Variant = arrays[Mesh.ARRAY_INDEX]
		if indices != null and (indices as PackedInt32Array).size() > 0:
			return (indices as PackedInt32Array).size() / 3
		return (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	return 0


static func _material_texture_size(material: Material) -> int:
	var biggest: int = 0
	if material is BaseMaterial3D:
		var tex: Texture2D = (material as BaseMaterial3D).albedo_texture
		if tex:
			biggest = maxi(tex.get_width(), tex.get_height())
	elif material is ShaderMaterial:
		var shader_material := material as ShaderMaterial
		if shader_material.shader:
			for uniform: Dictionary in shader_material.shader.get_shader_uniform_list():
				var value: Variant = shader_material.get_shader_parameter(uniform["name"])
				if value is Texture2D:
					biggest = maxi(biggest, maxi((value as Texture2D).get_width(), (value as Texture2D).get_height()))
	return biggest


static func make_table(rows: Array[Dictionary]) -> String:
	var lines: PackedStringArray = []
	lines.append("Stand %s, erzeugt mit `tools/asset_audit.gd` (Grafikstufe Mittel, ohne Kulissen-Kürzung im Splitscreen)." % Time.get_date_string_from_system())
	lines.append("")
	lines.append("| Minispiel | Dreiecke | Meshes | MultiMesh-Instanzen | Materialien | Draw Calls (geschätzt) | Textur max px | Lichter (mit Schatten) |")
	lines.append("|---|---|---|---|---|---|---|---|")
	for r: Dictionary in rows:
		var tri: String = "%d%s" % [r["triangles"], " ⚠" if int(r["triangles"]) > BUDGET_TRIANGLES else ""]
		var dc: String = "%d%s" % [r["draw_calls"], " ⚠" if int(r["draw_calls"]) > BUDGET_DRAW_CALLS else ""]
		var tex: String = "%d%s" % [r["max_texture"], " ⚠" if int(r["max_texture"]) > BUDGET_TEXTURE else ""]
		lines.append("| %s | %s | %d | %d | %d | %s | %s | %d (%d) |" % [r["name"], tri, r["meshes"], r["mm_instances"], r["materials"], dc, tex, r["lights"], r["shadow_lights"]])
	return "\n".join(lines)


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
