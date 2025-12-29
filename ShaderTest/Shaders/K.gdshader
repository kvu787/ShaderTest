shader_type spatial;
render_mode unshaded;

#include "res://Shaders/Inc/Colors.gdshaderinc"
#include "res://Shaders/Inc/Numbers.gdshaderinc"
#include "res://Shaders/Inc/Schlick.gdshaderinc"

uniform vec4 _BASE_COLOR : source_color = __BLUE;
uniform float _FACING_RATIO_POSITION_OF_BASE_COLOR : hint_range(0.0, 1.0) = __COSINE_30_DEG;
uniform bool _ENABLE_SHADING_SHIFT = false;
uniform float _SHADING_SHIFT_RATIO : hint_range(0, 1.0) = 0.5;
uniform float _SHADING_SHIFT_ROTATION_DEGREES : hint_range(0, 360.0) = 0.0;

vec2 rotate(vec2 uv, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    // Standard CCW Matrix: [ c  -s ]
    //                      [ s   c ]
    // GLSL Column-Major: vec2(c, s), vec2(-s, c)
    mat2 rotation_matrix = mat2(vec2(c, s), vec2(-s, c));
    return rotation_matrix * uv;
}

void fragment() {
	vec3 normal = normalize(NORMAL);

	float maxShadingShift = min(_FACING_RATIO_POSITION_OF_BASE_COLOR, 1.0 - _FACING_RATIO_POSITION_OF_BASE_COLOR);
	vec2 rotatedNormalXY = rotate(normal.xy, -1.0 * _SHADING_SHIFT_ROTATION_DEGREES * PI / 180.0);
	float shadingShift = float(_ENABLE_SHADING_SHIFT) * (rotatedNormalXY.x * _SHADING_SHIFT_RATIO * maxShadingShift);
	float facingRatioPositionOfBaseColor = clamp(_FACING_RATIO_POSITION_OF_BASE_COLOR - shadingShift, 0.0, 1.0);
	float facingRatio = clamp(normal.z, 0.0, 1.0);

	ALBEDO = vec3(
		ModifiedSchlicksBias_Safe(facingRatioPositionOfBaseColor, _BASE_COLOR.r, facingRatio),
		ModifiedSchlicksBias_Safe(facingRatioPositionOfBaseColor, _BASE_COLOR.g, facingRatio),
		ModifiedSchlicksBias_Safe(facingRatioPositionOfBaseColor, _BASE_COLOR.b, facingRatio));
}
