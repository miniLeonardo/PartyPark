shader_type spatial;
// Randlicht (Fresnel) als Zusatzdurchgang (next_pass) für Spielzeug-Plastik, siehe Look.RIM_LEVELS.
// Hellt die Kanten blickabhängig in der Horizontfarbe der Stimmung auf, unabhängig von der Sonne.
render_mode blend_add, unshaded, depth_draw_never, cull_back, shadows_disabled, fog_disabled;

uniform vec3 rim_color : source_color = vec3(1.0);
uniform float strength : hint_range(0.0, 2.0) = 0.2;
// Je höher, desto schmaler der Rand.
uniform float power : hint_range(0.5, 8.0) = 3.0;

void fragment() {
	float facing = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	ALBEDO = rim_color * pow(1.0 - facing, power) * strength;
}
