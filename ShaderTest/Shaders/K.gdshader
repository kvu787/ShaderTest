shader_type spatial;
render_mode unshaded;

#include "res://Shaders/Inc/Colors.gdshaderinc"
#include "res://Shaders/Inc/Numbers.gdshaderinc"
#include "res://Shaders/Inc/Schlick.gdshaderinc"

uniform vec4 _BASE_COLOR : source_color = __BLUE;
uniform float _COSINE_PHI_POSITION_OF_BASE_COLOR : hint_range(0.0, 1.0) = __COSINE_30_DEG;
uniform bool _ENABLE_SHADING_SHIFT = false;
uniform float _SHADING_SHIFT_RATIO : hint_range(0, 1.0) = 0.5;

void fragment() {
	vec3 normal = normalize(NORMAL);

	float maxShift = min(_COSINE_PHI_POSITION_OF_BASE_COLOR, 1.0 - _COSINE_PHI_POSITION_OF_BASE_COLOR);
	float shadingShift = float(_ENABLE_SHADING_SHIFT) * (normal.x * _SHADING_SHIFT_RATIO * maxShift);
	float facingRatioPositionOfBaseColor = clamp(_COSINE_PHI_POSITION_OF_BASE_COLOR - shadingShift, 0.0, 1.0);
	float facingRatio = clamp(normal.z, 0.0, 1.0);

	ALBEDO = vec3(
		ModifiedSchlicksBias_Safe(facingRatioPositionOfBaseColor, _BASE_COLOR.r, facingRatio),
		ModifiedSchlicksBias_Safe(facingRatioPositionOfBaseColor, _BASE_COLOR.g, facingRatio),
		ModifiedSchlicksBias_Safe(facingRatioPositionOfBaseColor, _BASE_COLOR.b, facingRatio));
}
