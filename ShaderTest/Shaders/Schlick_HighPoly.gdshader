shader_type spatial;
render_mode unshaded;

#define __BLUE vec4(0.039215688, 0.24705882, 0.78431374, 1)
#define __GRAY vec4(0.5, 0.5, 0.5, 1.0)

uniform vec4 _BASE_COLOR : source_color = __BLUE;

// √(3)/2 =  0.866025403784
uniform float _COSINE_PHI_POSITION_OF_BASE_COLOR : hint_range(0.0, 1.0) = 0.866025403784;

uniform bool _ENABLE_SHADING_SHIFT = false;

// 1/(1-√(3)/2) = 7.464101615
uniform float _SHADING_SHIFT : hint_range(7.464101615, 20.0) = 10.0;

float ModifiedSchlicksBias(float a, float b, float x) {
	float c1 = b * (1.0 - a);
	float c2 = b - a;
	float c3 = a * (1.0 - b);
	return (c1 * x) / (c2 * x + c3);
}

float ModifiedSchlicksBias_Safe(float a, float b, float x) {
	if ((a == 0.0) && (b == 0.0)) {
		return x;
	} else if ((a == 0.0) && (0.0 < b && b < 1.0)) {
		return 1.0;
	} else if ((a == 0.0) && (b == 1.0)) {
		return 1.0;
	} else if ((0.0 < a && a < 1.0) && (b == 0.0)) {
		return 0.0;
	} else if ((0.0 < a && a < 1.0) && (0.0 < b && b < 1.0)) {
		return ModifiedSchlicksBias(a, b, x);
	} else if ((0.0 < a && a < 1.0) && (b == 1.0)) {
		return 1.0;
	} else if ((a == 1.0) && (b == 0.0)) {
		return 0.0;
	} else if ((a == 1.0) && (0.0 < b && b < 1.0)) {
		return 0.0;
	} else if ((a == 1.0) && (b == 1.0)) {
		return x;
	}
}

void fragment() {
	vec3 normal = normalize(NORMAL);
	float cosPhi = normal.z;
	float facingRatio = clamp(cosPhi, 0.0, 1.0);
	float cosTheta = normal.x;
	float cosPhiPosShifted = (_COSINE_PHI_POSITION_OF_BASE_COLOR - float(_ENABLE_SHADING_SHIFT) * (cosTheta / _SHADING_SHIFT));

	ALBEDO = vec3(
		ModifiedSchlicksBias_Safe(cosPhiPosShifted, _BASE_COLOR.r, facingRatio),
		ModifiedSchlicksBias_Safe(cosPhiPosShifted, _BASE_COLOR.g, facingRatio),
		ModifiedSchlicksBias_Safe(cosPhiPosShifted, _BASE_COLOR.b, facingRatio));
}
