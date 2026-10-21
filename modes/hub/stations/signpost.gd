class_name HubSignpost
extends Node3D
## Hölzerner Wegweiserpfahl an Weggabelungen (D112).
## Zeigt mit beschrifteten Richtungspfeilen in die 4 Zonen des Parks.


func _ready() -> void:
	_build_signpost()


func _build_signpost() -> void:
	var wood_mat: Material = Look.surface(Color("#795548"), Look.Kind.WOOD)
	var arrow_mat: Material = Look.surface(Color("#f0ede6"), Look.Kind.WOOD)

	# 1. Holzpfahl (Höhe 2.8 m)
	var post := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.09
	cyl.bottom_radius = 0.12
	cyl.height = 2.8
	post.mesh = cyl
	post.material_override = wood_mat
	post.position = Vector3(0, 1.4, 0)
	post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(post)

	# 2. Pfeile in die 4 Richtungen
	var directions: Array[Dictionary] = [
		{"text": "Parkour & Turm", "rot_y": 0.0, "height": 2.5, "color": Color("#e74c3c")},
		{"text": "Rummel & Karussell", "rot_y": -90.0, "height": 2.2, "color": Color("#e67e22")},
		{"text": "Attraktionen", "rot_y": 180.0, "height": 1.9, "color": Color("#3498db")},
		{"text": "Spielzeug & Teich", "rot_y": 90.0, "height": 1.6, "color": Color("#2ecc71")},
	]

	for d: Dictionary in directions:
		var arrow_node := Node3D.new()
		arrow_node.position = Vector3(0, d["height"], 0)
		arrow_node.rotation_degrees = Vector3(0, d["rot_y"], 0)
		add_child(arrow_node)

		var plank := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(1.4, 0.24, 0.08)
		plank.mesh = box
		plank.material_override = Look.surface(d["color"], Look.Kind.WOOD)
		plank.position = Vector3(0.65, 0, 0)
		plank.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		arrow_node.add_child(plank)

		var tip := MeshInstance3D.new()
		var prism := PrismMesh.new()
		prism.size = Vector3(0.24, 0.28, 0.08)
		tip.mesh = prism
		tip.material_override = Look.surface(d["color"], Look.Kind.WOOD)
		tip.position = Vector3(1.45, 0, 0)
		tip.rotation_degrees = Vector3(0, 0, -90)
		tip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		arrow_node.add_child(tip)

		var lbl := Label3D.new()
		lbl.text = d["text"]
		lbl.font_size = 20
		lbl.outline_size = 5
		lbl.modulate = Color.WHITE
		lbl.outline_modulate = Color("#111111")
		lbl.position = Vector3(0.65, 0, 0.06)
		arrow_node.add_child(lbl)
