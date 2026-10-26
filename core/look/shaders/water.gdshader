shader_type spatial;
// Stilisiertes Wasser: zwei Farbtöne nach Tiefe, sanfte Wellen, Schaumkante an Ufern und Objekten,
// helle Glitzerflecken. Braucht den Tiefenpuffer (Forward+ und Mobile).
render_mode cull_back, specular_schlick_ggx, depth_draw_opaque;

uniform vec4 shallow_color : source_color = vec4(0.36, 0.78, 0.92, 1.0);
uniform vec4 deep_color : source_color = vec4(0.12, 0.42, 0.75, 1.0);
uniform vec4 foam_color : source_color = vec4(0.95, 0.98, 1.0, 1.0);
uniform float depth_range = 6.0;
uniform float foam_width = 0.55;
uniform float wave_height = 0.08;
uniform float wave_speed = 0.6;
uniform float sparkle_amount = 0.35;
uniform sampler2D depth_tex : hint_depth_texture, filter_linear;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME * wave_speed;
	VERTEX.y += (sin(world_pos.x * 0.35 + t) + sin(world_pos.z * 0.42 + t * 1.3)) * wave_height;
}

void fragment() {
	float scene_depth = texture(depth_tex, SCREEN_UV).r;
	vec4 world = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, scene_depth, 1.0);
	world.xyz /= world.w;
	float water_depth = clamp(-world.z - (-VERTEX.z), 0.0, 100.0);
	float d = clamp(water_depth / depth_range, 0.0, 1.0);
	vec3 col = mix(shallow_color.rgb, deep_color.rgb, d);
	float t = TIME * wave_speed;
	float n = noise(world_pos.xz * 0.9 + vec2(t * 0.4, -t * 0.3));
	float foam_line = 1.0 - smoothstep(foam_width * (0.6 + 0.5 * n), foam_width * (0.6 + 0.5 * n) + 0.08, water_depth);
	// Sanfte Farbschlieren und vereinzelte kleine Glitzerpunkte
	float streak = noise(world_pos.xz * 0.18 + vec2(t * 0.05, t * 0.08));
	col = mix(col, col * 1.12, smoothstep(0.55, 0.8, streak));
	float sparkle = step(0.94, noise(world_pos.xz * 5.5 + vec2(t * 0.9, t * 0.6))) * step(0.5, noise(world_pos.xz * 0.7 - vec2(t * 0.2))) * sparkle_amount;
	col = mix(col, foam_color.rgb, clamp(foam_line + sparkle, 0.0, 1.0));
	ALBEDO = col;
	ROUGHNESS = 0.42;
	SPECULAR = 0.2;
}
