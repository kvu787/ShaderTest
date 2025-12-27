shader_type spatial;
render_mode unshaded;

#include "Colors.gdshaderinc"
#include "Schlick.gdshaderinc"

uniform vec4 _BASE_COLOR : source_color = __PURPLE;
// √(3)/2 =  0.866025403784
uniform float _COSINE_PHI_POSITION_OF_BASE_COLOR : hint_range(0.0, 1.0) = 0.866025403784;
uniform bool _ENABLE_SHADING_SHIFT = false;
// 1/(1-√(3)/2) = 7.464101615
uniform float _SHADING_SHIFT : hint_range(7.464101615, 20.0) = 10.0;

void fragment() {
	vec3 normal = normalize(NORMAL);
	float cosineTheta = normal.x;
	float cosinePhi = normal.z;

	float cosinePhiPositionShifted = (_COSINE_PHI_POSITION_OF_BASE_COLOR - float(_ENABLE_SHADING_SHIFT) * (cosineTheta / _SHADING_SHIFT));
	float facingRatio = clamp(cosinePhi, 0.0, 1.0);

	ALBEDO = vec3(
		ModifiedSchlicksBias_Safe(cosinePhiPositionShifted, _BASE_COLOR.r, facingRatio),
		ModifiedSchlicksBias_Safe(cosinePhiPositionShifted, _BASE_COLOR.g, facingRatio),
		ModifiedSchlicksBias_Safe(cosinePhiPositionShifted, _BASE_COLOR.b, facingRatio));
}
