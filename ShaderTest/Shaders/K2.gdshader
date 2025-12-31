shader_type spatial;
render_mode unshaded;

#include "res://Shaders/Inc/Colors.gdshaderinc"
#include "res://Shaders/Inc/Math.gdshaderinc"
#include "res://Shaders/Inc/Numbers.gdshaderinc"
#include "res://Shaders/Inc/Schlick.gdshaderinc"

uniform vec4 _BASE_COLOR : source_color = __BLUE;
uniform float _FACING_RATIO_POSITION_OF_BASE_COLOR : hint_range(0.0, 1.0) = __COSINE_45_DEG;
uniform float _SHIFT : hint_range(0.0, 0.999) = 0.0;
uniform float _ROTATION : hint_range(0.0, 90.0) = 0.0;
uniform float _RADIUS : hint_range(0.0, 2.0) = 1.0;

float fz(float x, float y) {
	return sqrt(1.0 - pow(x, 2.0) - pow(y, 2.0));
}

float fx(float y, float z) {
	return sqrt(1.0 - pow(y, 2.0) - pow(z, 2.0));
}

float FacingRatio(float x, float y, float xShift) {
	return
		fz(
			MapRange(
				SchlickA(
					MapRange(
						x,
						-fx(y, 0.0), fx(y, 0.0), 0.0, 1.0),
					MapRange(
						xShift,
						-1.0, 1.0, 0.0, 1.0)),
				0.0, 1.0, -fx(y, 0.0), fx(y, 0.0)),
			y);
}

void fragment() {
	vec3 normal = normalize(NORMAL);
	if (GetRadius(normal.xy) >= _RADIUS) {
		ALBEDO = vec3(0.0, 0.0, 0.0);
	} else {
		vec2 rotatedNormalXY = RotateXY(normal.xy, -1.0 * _ROTATION * PI / 180.0);
		float facingRatio = FacingRatio(rotatedNormalXY.x, rotatedNormalXY.y, _SHIFT);

		ALBEDO = vec3(
			Schlick1(_FACING_RATIO_POSITION_OF_BASE_COLOR, _BASE_COLOR.r, facingRatio),
			Schlick1(_FACING_RATIO_POSITION_OF_BASE_COLOR, _BASE_COLOR.g, facingRatio),
			Schlick1(_FACING_RATIO_POSITION_OF_BASE_COLOR, _BASE_COLOR.b, facingRatio));
	}
}
