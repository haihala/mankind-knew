shader_type canvas_item;

uniform sampler2D[5] patterns;
uniform float[5] pattern_scales;
uniform float[5] pattern_angles;
uniform float[5] beliefs;
uniform float hat_height;

void fragment() {
	vec2 coords = vec2(1.0-2.0*UV.x, 1.0-UV.y);

	float bottom = 0.0;
	COLOR.a = 0.0;
	for (int i = 0; i < 5; i++) {
		float top = bottom + beliefs[i];
		if (coords.y > bottom && coords.y < top) {
			// In this segment
			vec2 pos = UV*pattern_scales[i]*vec2(1.0, hat_height);
			COLOR = texture(patterns[i], fract(pos));
			break;
		}
		bottom = top;
	}
}
