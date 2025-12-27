shader_type spatial;
render_mode unshaded;

#include "Colors.gdshaderinc"
#include "Schlick.gdshaderinc"

uniform vec4 _BASE_COLOR : source_color = __PINK_BRIGHT;
// √(3)/3 =  0.5773502692
uniform float _COSINE_PHI_POSITION_OF_BASE_COLOR : hint_range(0.0, 1.0) = 0.5773502692;
uniform bool _ENABLE_SHADING_SHIFT = true;
// 1/(1-√(3)/3) = 2.366025404
uniform float _SHADING_SHIFT : hint_range(2.366025404, 30.0) = 7.0;

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
