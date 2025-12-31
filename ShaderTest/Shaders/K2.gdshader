shader_type spatial;
render_mode unshaded;

#include "res://Shaders/Inc/Colors.gdshaderinc"
#include "res://Shaders/Inc/Math.gdshaderinc"
#include "res://Shaders/Inc/Numbers.gdshaderinc"
#include "res://Shaders/Inc/Schlick.gdshaderinc"

uniform vec4 _BASE_COLOR : source_color = __BLUE;
uniform float _FACING_RATIO_POSITION_OF_BASE_COLOR : hint_range(0.0, 1.0) = __COSINE_45_DEG;
uniform float _SHIFT : hint_range(0.0, 1.0) = 0.0;
uniform float _ROTATION : hint_range(0.0, 180.0) = 0.0;
uniform bool _ROTATION_FLIP = false;

float ZComponent(float x, float y) {
	return sqrt(1.0 - pow(x, 2.0) - pow(y, 2.0));
}

float XComponent(float y, float z) {
	return sqrt(1.0 - pow(y, 2.0) - pow(z, 2.0));
}

float FacingRatio(float x, float y, float xShift) {
	return
		ZComponent(
			MapRange(
				SchlickA(
					MapRange(
						x,
						-XComponent(y, 0.0), XComponent(y, 0.0), 0.0, 1.0),
					MapRange(
						xShift,
						-1.0, 1.0, 0.0, 1.0)),
				0.0, 1.0, -XComponent(y, 0.0), XComponent(y, 0.0)),
			y);
}

void fragment() {
	vec3 normal = normalize(NORMAL);

	vec2 rotatedNormalXY = RotateXY(normal.xy, -1.0 * (_ROTATION + float(_ROTATION_FLIP) * 180.0) * PI / 180.0);
	float facingRatio = FacingRatio(rotatedNormalXY.x, rotatedNormalXY.y, _SHIFT);

	ALBEDO = vec3(
		SchlickAB(facingRatio, _FACING_RATIO_POSITION_OF_BASE_COLOR, _BASE_COLOR.r),
		SchlickAB(facingRatio, _FACING_RATIO_POSITION_OF_BASE_COLOR, _BASE_COLOR.g),
		SchlickAB(facingRatio, _FACING_RATIO_POSITION_OF_BASE_COLOR, _BASE_COLOR.b));
}
