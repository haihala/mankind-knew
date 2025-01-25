shader_type canvas_item;

uniform vec4[5] colors;
uniform float[5] beliefs;

void fragment() {
	vec2 coords = vec2(1.0-2.0*UV.x, 1.0-UV.y);
	
	float bottom = 0.0;
	COLOR.a = 0.0;
	for (int i = 0; i < 5; i++) {
		float top = bottom + beliefs[i];
		if (coords.y > bottom && coords.y < top) {
			// In this segment
			COLOR = colors[i];
			break;
		}
		bottom = top;
	}
}

