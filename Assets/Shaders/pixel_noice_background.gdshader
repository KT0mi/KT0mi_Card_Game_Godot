shader_type canvas_item;

uniform vec4 color_1 : source_color = vec4(0.10, 0.09, 0.16, 1.0);
uniform vec4 color_2 : source_color = vec4(0.22, 0.10, 0.30, 1.0);
uniform vec4 color_3 : source_color = vec4(0.05, 0.25, 0.35, 1.0);
uniform float pixel_size : hint_range(1.0, 32.0) = 6.0;
uniform float scale : hint_range(0.5, 10.0) = 3.0;
uniform float speed : hint_range(0.0, 2.0) = 0.15;
uniform float warp_strength : hint_range(0.0, 2.0) = 0.6;

vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
			dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
		mix(dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
			dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x),
		u.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		value += amp * noise(p);
		p *= 2.0;
		amp *= 0.5;
	}
	return value;
}


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//Snap to a coarse pixel grid FIRST -- this is what turns smooth noise
	//into blocky pixel-art noise instead of a soft gradient.
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 pixelated_uv = floor(UV * screen_size / pixel_size) * pixel_size / screen_size;
	
	vec2 p = pixelated_uv * scale;
	
	//Domain warp: feed noise through itself for the "flowing liquid" look
	vec2 warp = vec2(
		fbm(p + TIME * speed),
		fbm(p + vec2(5.2, 1.3) + TIME * speed)
	);
	float n = fbm(p + warp * warp_strength);
	n = n * 0.5 + 0.5; //remap -1..1 -> 0..1
	
	vec4 col;
	if (n < 0.5) {
		col = mix(color_1, color_2, n * 2.0);
	} else {
		col = mix(color_2, color_3, (n - 0.5) * 2.0);
	}
	
	COLOR = col;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
