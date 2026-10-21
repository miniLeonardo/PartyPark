class_name Look
extends RefCounted
## Gemeinsamer Look von Partypark (D85: „Spielzeug-Plastik“, keine Umrisslinien): Umgebung je Stimmung
## (Himmel, Sonne, Nebel, Glow, SSAO), Materialien je Stoffart, Figurenmaterial und das Umfärben fremder
## Modelle. Verbindlich beschrieben in docs/ART_GUIDE.md. Arenen, StageKit und Menüs holen ihr Aussehen von hier.

enum Mood { NOON, GOLDEN, EVENING }
## Stoffarten für `surface()`. Bestimmen Rauheit, Klarlack und Metallanteil (ART_GUIDE Abschnitt 4).
enum Kind { PLASTIC, GROUND, GRASS, WOOD, METAL, FABRIC, STONE, RUBBER, GLOSSY }

## Werte der Option „Tageszeit“ (D86).
enum TimeOfDay { DAY_CYCLE, NOON, GOLDEN, EVENING }
const TIME_OF_DAY_NAMES: Array[String] = ["Tagesverlauf", "Nachmittag", "Goldene Stunde", "Abend"]
const MOOD_NAMES: Array[String] = ["Nachmittag", "Goldene Stunde", "Abendrummel"]

const WATER_SHADER: Shader = preload("res://core/look/shaders/water.gdshader")

## Aktuelle Stimmung. Wird vor dem Aufbau einer Szene gesetzt (`use_mood`, `mood_for_progress`).
static var mood: int = Mood.NOON

static var _material_cache: Dictionary = {}


## Himmel, Sonne und Umgebung je Stimmung. Feinabstimmung nur hier (ART_GUIDE Abschnitt 3).
const MOODS: Dictionary = {
	Mood.NOON: {
		"sky_top": Color("#3f8fe6"), "sky_horizon": Color("#cde8ff"), "ground_horizon": Color("#cde8ff"), "ground_bottom": Color("#8fb5d6"),
		"sun_color": Color("#fff2dc"), "sun_energy": 1.3, "sun_rotation": Vector3(-55.0, -35.0, 0.0),
		"ambient_energy": 0.8, "fog_color": Color("#d4ebff"), "fog_begin": 45.0, "fog_end": 160.0, "fog_density": 0.45,
		"exposure": 1.05, "glow": 0.25, "fill_color": Color("#9cc7ff"), "fill_energy": 0.0, "bulbs": 0.0, "lamp_lights": false,
	},
	Mood.GOLDEN: {
		"sky_top": Color("#5b7fd1"), "sky_horizon": Color("#ffd09a"), "ground_horizon": Color("#ffd09a"), "ground_bottom": Color("#b9a08f"),
		"sun_color": Color("#ffc07a"), "sun_energy": 1.45, "sun_rotation": Vector3(-24.0, -62.0, 0.0),
		"ambient_energy": 0.75, "fog_color": Color("#f6c99c"), "fog_begin": 35.0, "fog_end": 140.0, "fog_density": 0.5,
		"exposure": 1.0, "glow": 0.5, "fill_color": Color("#8fa6ff"), "fill_energy": 0.15, "bulbs": 2.0, "lamp_lights": false,
	},
	Mood.EVENING: {
		"sky_top": Color("#1c2257"), "sky_horizon": Color("#e0767a"), "ground_horizon": Color("#a0577a"), "ground_bottom": Color("#2a2350"),
		"sun_color": Color("#ffa36e"), "sun_energy": 0.65, "sun_rotation": Vector3(-28.0, -70.0, 0.0),
		"ambient_energy": 1.1, "fog_color": Color("#7c5a8c"), "fog_begin": 30.0, "fog_end": 120.0, "fog_density": 0.55,
		"exposure": 1.15, "glow": 1.0, "fill_color": Color("#8d9bff"), "fill_energy": 0.4, "bulbs": 6.0, "lamp_lights": true,
	},
}


static func mood_value(key: String) -> Variant:
	return (MOODS[mood] as Dictionary)[key]


# --- Stimmung wählen (D86) ---

## Setzt die Stimmung direkt (z. B. Stilproben, Tests).
static func use_mood(value: int) -> void:
	if value != mood:
		mood = value
		clear_cache()


## Stimmung für einen Turnierfortschritt 0..1 nach der Option „Tageszeit“: beim Tagesverlauf
## erstes Drittel Nachmittag, zweites goldene Stunde, letztes Drittel Abendrummel.
static func mood_for_progress(progress: float) -> int:
	match Settings.time_of_day:
		TimeOfDay.NOON:
			return Mood.NOON
		TimeOfDay.GOLDEN:
			return Mood.GOLDEN
		TimeOfDay.EVENING:
			return Mood.EVENING
	if progress < 1.0 / 3.0:
		return Mood.NOON
	if progress < 2.0 / 3.0:
		return Mood.GOLDEN
	return Mood.EVENING


## Stimmung für Titel, Menüs und Siegerehrung: beim Tagesverlauf Abendrummel, sonst die feste Tageszeit.
static func menu_mood() -> int:
	return mood_for_progress(1.0)


## Ersetzt die alte Code-Umgebung aus StageKit: Himmel, AgX, Nebel, Glow, SSAO (nur Hoch), Sonne.
static func add_environment(parent: Node) -> WorldEnvironment:
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"
	world.environment = make_environment()
	parent.add_child(world)
	add_sun(parent)
	return world


static func make_environment() -> Environment:
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = mood_value("sky_top")
	sky_material.sky_horizon_color = mood_value("sky_horizon")
	sky_material.ground_horizon_color = mood_value("ground_horizon")
	sky_material.ground_bottom_color = mood_value("ground_bottom")
	sky_material.sky_curve = 0.12
	sky_material.sun_angle_max = 12.0
	var sky := Sky.new()
	sky.sky_material = sky_material
	sky.radiance_size = Sky.RADIANCE_SIZE_64
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = mood_value("ambient_energy")
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.tonemap_exposure = mood_value("exposure")
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_DEPTH
	env.fog_light_color = mood_value("fog_color")
	env.fog_density = mood_value("fog_density")
	env.fog_depth_begin = mood_value("fog_begin")
	env.fog_depth_end = mood_value("fog_end")
	env.fog_sky_affect = 0.0
	env.glow_enabled = glow_enabled()
	env.glow_intensity = mood_value("glow")
	env.glow_bloom = 0.02
	env.glow_hdr_threshold = 0.9
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	env.ssao_enabled = ssao_enabled()
	env.ssao_radius = 1.2
	env.ssao_intensity = 1.4
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.2
	return env


static func add_sun(parent: Node) -> DirectionalLight3D:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = mood_value("sun_rotation")
	sun.light_color = mood_value("sun_color")
	sun.light_energy = mood_value("sun_energy")
	sun.shadow_enabled = Settings.shadows_enabled()
	sun.shadow_blur = 1.5
	sun.directional_shadow_max_distance = 60.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.add_to_group(Settings.STAGE_LIGHTS_GROUP)
	parent.add_child(sun)
	var fill_energy: float = mood_value("fill_energy")
	if fill_energy > 0.0:
		var fill := DirectionalLight3D.new()
		fill.name = "Fill"
		fill.rotation_degrees = Vector3(-35.0, 140.0, 0.0)
		fill.light_color = mood_value("fill_color")
		fill.light_energy = fill_energy
		fill.shadow_enabled = false
		parent.add_child(fill)
	return sun


static func glow_enabled() -> bool:
	return Settings.graphics_quality >= 1


static func ssao_enabled() -> bool:
	return Settings.graphics_quality >= 2


## Kulissen-Details (Zuschauer, kleine Deko, Lampenlichter) nur ab Mittel.
static func details_enabled() -> bool:
	return Settings.graphics_quality >= 1


## Stärke der Glühbirnen (Emission) in der aktuellen Stimmung.
static func bulb_energy() -> float:
	return mood_value("bulbs")


## Echte Lampenlichter (OmniLight ohne Schatten) nur im Abendrummel und ab Mittel.
static func lamp_lights_enabled() -> bool:
	return bool(mood_value("lamp_lights")) and details_enabled()


# --- Materialien (ART_GUIDE Abschnitt 4) ---

## Material für eine Fläche in einer Farbe. Gleiche Anfragen teilen sich ein Material.
static func surface(color: Color, kind: int = Kind.PLASTIC, texture: Texture2D = null) -> StandardMaterial3D:
	var key := "%d|%s|%d" % [kind, color.to_html(), texture.get_instance_id() if texture else 0]
	if _material_cache.has(key):
		return _material_cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	if texture:
		m.albedo_texture = texture
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	match kind:
		Kind.PLASTIC:
			m.roughness = 0.32
			m.clearcoat_enabled = true
			m.clearcoat = 0.5
			m.clearcoat_roughness = 0.25
			m.rim_enabled = true
			m.rim = 0.2
			m.rim_tint = 0.4
		Kind.GLOSSY:
			m.roughness = 0.2
			m.clearcoat_enabled = true
			m.clearcoat = 0.8
			m.clearcoat_roughness = 0.15
			m.rim_enabled = true
			m.rim = 0.3
			m.rim_tint = 0.4
		Kind.METAL:
			m.roughness = 0.3
			m.metallic = 0.6
		Kind.RUBBER:
			m.roughness = 0.6
		Kind.WOOD, Kind.FABRIC:
			m.roughness = 0.8
		Kind.GRASS, Kind.GROUND:
			m.roughness = 0.95
		_:
			m.roughness = 0.85
	_material_cache[key] = m
	return m


## Material der Spielfigur: Spielerfarbe dominant, glänzend wie lackiertes Spielzeug, Randlicht hebt die
## Figur vom Boden ab. Je Figur ein eigenes Material (Farbe ändert sich z. B. beim Ausblassen).
static func character_material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.22
	m.clearcoat_enabled = true
	m.clearcoat = 0.8
	m.clearcoat_roughness = 0.15
	m.rim_enabled = true
	m.rim = 0.4
	m.rim_tint = 0.3
	return m


## Leuchtendes Material für Glühbirnen und Lichterketten (Stärke je Stimmung).
static func bulb_material(color: Color) -> StandardMaterial3D:
	var key := "bulb|%d|%s" % [mood, color.to_html()]
	if _material_cache.has(key):
		return _material_cache[key]
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = color
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = 0.4 + bulb_energy()
	_material_cache[key] = m
	return m


static func water_material() -> ShaderMaterial:
	var key := "water|%d" % mood
	if _material_cache.has(key):
		return _material_cache[key]
	var m := ShaderMaterial.new()
	m.shader = WATER_SHADER
	if mood == Mood.EVENING:
		m.set_shader_parameter("shallow_color", Color("#3f7fb0"))
		m.set_shader_parameter("deep_color", Color("#1b2f66"))
	elif mood == Mood.GOLDEN:
		m.set_shader_parameter("shallow_color", Color("#58b8d6"))
		m.set_shader_parameter("deep_color", Color("#1d5fa8"))
	_material_cache[key] = m
	return m


## Färbt ein importiertes Modell (z. B. Kenney-GLB) auf den Partypark-Stil um: jede Oberfläche bekommt
## das Stilmaterial der Stoffart mit der Original-Farbtextur; `tint` färbt zusätzlich ein (Weiß = unverändert).
static func restyle(root: Node, kind: int = Kind.PLASTIC, tint: Color = Color.WHITE) -> void:
	for mesh_instance: MeshInstance3D in _mesh_instances(root):
		var mesh: Mesh = mesh_instance.mesh
		if mesh == null:
			continue
		for surface_index: int in mesh.get_surface_count():
			var original: Material = mesh_instance.get_active_material(surface_index)
			var texture: Texture2D = null
			var color: Color = tint
			if original is BaseMaterial3D:
				texture = (original as BaseMaterial3D).albedo_texture
				color = (original as BaseMaterial3D).albedo_color * tint
			mesh_instance.set_surface_override_material(surface_index, surface(color, kind, texture))


static func _mesh_instances(root: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		result.append(root as MeshInstance3D)
	for child: Node in root.get_children():
		result.append_array(_mesh_instances(child))
	return result


## Leert den Material-Zwischenspeicher, z. B. nach Wechsel von Stimmung oder Grafikstufe.
static func clear_cache() -> void:
	_material_cache.clear()
