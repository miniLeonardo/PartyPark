class_name UiStyle
extends RefCounted
## Gemeinsame Bausteine für die Platzhalter-Oberfläche. Schriftgrößen beziehen sich auf 1920×1080.

const TEXT_COLOR: Color = Color(1, 1, 1)
const MUTED_COLOR: Color = Color(1, 1, 1, 0.6)
const PANEL_COLOR: Color = Color(0.08, 0.09, 0.14, 0.88)


static func make_label(text: String, size: int, color: Color = TEXT_COLOR) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", maxi(4, size / 8))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


static func make_panel_style(fill: Color, border: Color = Color.TRANSPARENT, border_width: int = 0, radius: int = 24) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(24.0)
	return style


static func make_panel(fill: Color, border: Color = Color.TRANSPARENT, border_width: int = 0) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", make_panel_style(fill, border, border_width))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


## Vollbild-Container, der seinen Inhalt mittig hält.
static func make_center_root() -> CenterContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return center
