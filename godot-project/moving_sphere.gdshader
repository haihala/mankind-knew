shader_type canvas_item;

uniform vec4 color : source_color;
uniform float phase: hint_range(0.0, 1.0, 0.1);

const float min_distance = 0.2;
const float max_distance = 0.8;
const float radius = 0.2;
const int ball_count = 8;
const float outline_thickness = 0.3;

void fragment() {
	vec2 centered = 2.0*(UV - vec2(0.5));
	float dist = min_distance + phase * (max_distance-min_distance);

	COLOR.a = 0.0;
	float angle_mul = 2.0*PI/float(ball_count);
	for (int i = 0; i < ball_count; i++) {
		float ang = angle_mul * float(i);
		vec2 ball_pos = dist * vec2(sin(ang), cos(ang));
		if (length(centered - ball_pos) < radius * (1.0-outline_thickness)) {
			COLOR = color;
			break;
		}
		
		if (length(centered - ball_pos) < radius) {
			COLOR.rgba = vec4(1.0);
			break;
		}
	}
}