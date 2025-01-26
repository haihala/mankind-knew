shader_type canvas_item;

uniform bool use_colors;
uniform sampler2D[5] patterns : source_color;
uniform float[5] pattern_scales;
uniform float[5] beliefs;
uniform float hat_height;

const float roundness_squishing = 1.0 / 45.0;

const vec4 colors[5] = {
	vec4(255.0, 53.0, 53.0, 255.0) / 255.0,
	vec4(0.0, 211.0, 71.0, 255.0) / 255.0,
	vec4(0.0, 170.0, 255.0, 255.0) / 255.0,
	vec4(176.0, 29.0, 218.0, 255.0) / 255.0,
	vec4(255.0, 201.0, 0.0, 255.0) / 255.0
 };

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
			if (use_colors) {
				COLOR = colors[i];
			} else {
				// If this line is uncommented, no matter if it gets exectued or not, the game won't run on mobile
				//COLOR = texture(patterns[i], fract(pos));
			}
		}
		bottom += beliefs[i];
	}
}
