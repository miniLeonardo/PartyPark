class_name HubMinigameStation
extends Node3D
## Minispiel-Attraktionsbude im Freizeitpark (D109).
## Liebevoll gestaltete Kirmes-Bude mit Themen-Wimpel, Namensschild und
## leuchtender Aktivierungs-Platte (HubActivationPad).

signal activated(info: MinigameInfo)

@export var minigame_id: StringName = &""
var info: MinigameInfo
var activation_pad: HubActivationPad


func _ready() -> void:
	if not minigame_id.is_empty():
		info = MinigameRegistry.get_info(minigame_id)
	_build_booth()


func _build_booth() -> void:
	var title: String = info.display_name if info != null else String(minigame_id)
	var format_str: String = "FFA"
	if info != null and not info.formats.is_empty():
		format_str = TeamFormat.display_name(info.formats[0])

	var wood_mat: Material = Look.surface(Color("#8d6e63"), Look.Kind.WOOD)
	var counter_mat: Material = Look.surface(Color("#d7ccc8"), Look.Kind.WOOD)
	var roof_color: Color = _color_for_format(info.formats[0] if info != null and not info.formats.is_empty() else 0)

	# 1. Theke / Unterbau
	var counter := StageKit.add_box(self, Vector3(3.2, 1.1, 1.4), Vector3(0, 0.55, 0), Color("#795548"), Vector3.ZERO, Look.Kind.WOOD)
	counter.name = "Counter"

	# Thekenplatte
	var top := StageKit.add_box(self, Vector3(3.4, 0.15, 1.6), Vector3(0, 1.15, 0), Color("#d7ccc8"), Vector3.ZERO, Look.Kind.WOOD)
	top.name = "CounterTop"

	# 2. Vier Dachpfosten
	for x: float in [-1.5, 1.5]:
		for z: float in [-0.65, 0.65]:
			var post := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.06
			cyl.bottom_radius = 0.08
			cyl.height = 2.4
			post.mesh = cyl
			post.material_override = wood_mat
			post.position = Vector3(x, 2.3, z)
			post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(post)

	# 3. Gestreiftes Baldachin-Dach
	var roof := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(3.6, 1.0, 1.8)
	roof.mesh = prism
	roof.material_override = Look.surface(roof_color, Look.Kind.FABRIC)
	roof.position = Vector3(0, 3.7, 0)
	add_child(roof)

	# 4. Namensschild & Format-Badge
	var sign_mesh := MeshInstance3D.new()
	var s_box := BoxMesh.new()
	s_box.size = Vector3(2.8, 0.6, 0.1)
	sign_mesh.mesh = s_box
	sign_mesh.material_override = Look.surface(Color("#f0ede6"), Look.Kind.WOOD)
	sign_mesh.position = Vector3(0, 3.0, 0.9)
	sign_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sign_mesh)

	var label := Label3D.new()
	label.text = "%s\n[%s]" % [title, format_str]
	label.font_size = 28
	label.outline_size = 6
	label.modulate = Color("#222222")
	label.outline_modulate = Color.WHITE
	label.position = Vector3(0, 3.0, 0.96)
	add_child(label)

	# 5. Aktivierungs-Pad vor der Theke (Z = 2.6)
	activation_pad = HubActivationPad.new()
	activation_pad.name = "Pad"
	activation_pad.position = Vector3(0, 0, 2.6)
	activation_pad.pad_radius = 1.8
	activation_pad.activated.connect(_on_pad_activated)
	add_child(activation_pad)


func _color_for_format(fmt: int) -> Color:
	match fmt:
		TeamFormat.Format.FFA:
			return Color("#e74c3c") # Rot
		TeamFormat.Format.TWO_VS_TWO:
			return Color("#3498db") # Blau
		TeamFormat.Format.ONE_VS_THREE:
			return Color("#9b59b6") # Lila
		TeamFormat.Format.COOP_VS_CPU:
			return Color("#2ecc71") # Grün
		_:
			return Color("#f39c12")


func _on_pad_activated() -> void:
	if info != null:
		activated.emit(info)
