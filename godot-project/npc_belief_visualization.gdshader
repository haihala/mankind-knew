shader_type canvas_item;

uniform vec4 color : source_color;

void fragment() {
	vec2 centered = 2.0*(UV - vec2(0.5));
	if (length(centered) < 1.0) {
		COLOR = color;
	} else {
		COLOR.a = 0.0;
	}
}

