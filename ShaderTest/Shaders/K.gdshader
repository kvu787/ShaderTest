shader_type spatial;
render_mode unshaded;

#include "res://Shaders/Inc/Colors.gdshaderinc"
#include "res://Shaders/Inc/Numbers.gdshaderinc"
#include "res://Shaders/Inc/Schlick.gdshaderinc"

uniform vec4 _BASE_COLOR : source_color = __BLUE;
uniform float _COSINE_PHI_POSITION_OF_BASE_COLOR : hint_range(0.0, 1.0) = __COSINE_30_DEG;
uniform bool _ENABLE_SHADING_SHIFT = false;
uniform float _SHADING_SHIFT : hint_range(0, 1.0) = 0.5;

void fragment() {
	vec3 normal = normalize(NORMAL);
	float cosineTheta = normal.x;
	float cosinePhi = normal.z;

	float maxShift = min(_COSINE_PHI_POSITION_OF_BASE_COLOR, abs(1.0 - _COSINE_PHI_POSITION_OF_BASE_COLOR));
	float cosinePhiPositionShifted = (_COSINE_PHI_POSITION_OF_BASE_COLOR - float(_ENABLE_SHADING_SHIFT) * (cosineTheta * _SHADING_SHIFT * maxShift));
	cosinePhiPositionShifted = clamp(cosinePhiPositionShifted, 0.0, 1.0);
	float facingRatio = clamp(cosinePhi, 0.0, 1.0);

	ALBEDO = vec3(
		ModifiedSchlicksBias_Safe(cosinePhiPositionShifted, _BASE_COLOR.r, facingRatio),
		ModifiedSchlicksBias_Safe(cosinePhiPositionShifted, _BASE_COLOR.g, facingRatio),
		ModifiedSchlicksBias_Safe(cosinePhiPositionShifted, _BASE_COLOR.b, facingRatio));
}
