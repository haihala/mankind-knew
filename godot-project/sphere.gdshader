shader_type canvas_item;

uniform vec4 color : source_color;
uniform sampler2D pattern : source_color;
uniform float pattern_scale = 1.0;
uniform float padding = 0.2;

void fragment() {
	vec2 centered = 2.0*(UV - vec2(0.5));
	if (length(centered) < 1.0 - padding) {
		COLOR = texture(pattern, fract(UV * pattern_scale)) * color;
	} else {
		COLOR.a = 0.0;
	}
}