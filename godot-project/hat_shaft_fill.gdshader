shader_type canvas_item;

uniform sampler2D[5] patterns : source_color;
uniform vec4[5] colors : source_color;
uniform float[5] pattern_scales;
uniform float[5] beliefs;
uniform float hat_height;

const float roundness_squishing = 1.0 / 45.0;

void fragment() {
	vec2 coords = vec2(1.0-2.0*UV.x, 1.0-UV.y);

	float thickness = pow(abs(coords.x), 2.0) * roundness_squishing;
	float inverse_thickness = roundness_squishing - thickness;
	float bottom = thickness;
	COLOR.a = 0.0;

	for (int i = 0; i < 5; i++) {
		if (beliefs[i] <= 0.001) {
			continue;
		}
		float top = bottom + beliefs[i] + (2.0 * inverse_thickness);
		if (coords.y > bottom && coords.y < top) {
			vec2 pos = UV*pattern_scales[i] * vec2(1.0, hat_height);
			//COLOR = texture(patterns[i], fract(pos));
			//COLOR = texture(patterns[i], fract(pos));
			COLOR = colors[i];
		}
		bottom += beliefs[i];
	}
}
