class_name SplitScreen
extends CanvasLayer
## Geteilter Bildschirm (D49) für Ego-Minispiele: 2×2-Raster aus SubViewports, die die Welt der
## Hauptansicht teilen. Jede Ansicht hat eine eigene Camera3D und eine Overlay-Fläche für HUD-Elemente.
## Während der SplitScreen existiert, rendert die Hauptansicht kein 3D (spart einen ganzen Durchgang).
## Kameras hängen in der Gruppe "fx_cameras", damit Fx.shake() sie erreicht.

## Rendermaske je Ansicht: Ebene 1 ist die Welt, Ebene 2 + i gehört Spieler i (wird in Ansicht i ausgeblendet).
const WORLD_LAYER: int = 1

var cameras: Array[Camera3D] = []
var overlays: Array[Control] = []
var viewports: Array[SubViewport] = []

var _main_viewport: Viewport


func _init(count: int = 4) -> void:
	layer = 1
	var background := ColorRect.new()
	background.color = Color(0.05, 0.05, 0.07)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.set_anchors_preset(Control.PRESET_FULL_RECT)
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(grid)
	for i: int in count:
		var cell := Control.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		grid.add_child(cell)
		var container := SubViewportContainer.new()
		container.stretch = true
		container.set_anchors_preset(Control.PRESET_FULL_RECT)
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(container)
		var viewport := SubViewport.new()
		viewport.audio_listener_enable_3d = false
		container.add_child(viewport)
		var camera := Camera3D.new()
		camera.fov = 75.0
		camera.cull_mask = 0xFFFFF
		camera.add_to_group(&"fx_cameras")
		viewport.add_child(camera)
		camera.current = true
		var overlay := Control.new()
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(overlay)
		viewports.append(viewport)
		cameras.append(camera)
		overlays.append(overlay)


func _ready() -> void:
	_main_viewport = get_viewport()
	_main_viewport.disable_3d = true
	for viewport: SubViewport in viewports:
		Settings.apply_graphics_to_viewport(viewport)


func _exit_tree() -> void:
	if _main_viewport != null:
		_main_viewport.disable_3d = false


## Ebenen-Bit des Spielers i (für Figur-Meshes und die Kameramaske).
static func player_layer_bit(i: int) -> int:
	return 1 << (WORLD_LAYER + i)


## Blendet in Ansicht i die eigene Figur aus.
func hide_layer_in_view(view: int, layer_bit: int) -> void:
	cameras[view].cull_mask = 0xFFFFF & ~layer_bit


## Setzt rekursiv die Render-Ebene aller sichtbaren Knoten (z. B. einer Spielfigur).
static func set_render_layer(node: Node, layer_bit: int) -> void:
	var visual := node as VisualInstance3D
	if visual != null:
		visual.layers = layer_bit
	for child: Node in node.get_children():
		set_render_layer(child, layer_bit)
