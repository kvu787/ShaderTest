shader_type spatial;
render_mode unshaded;
render_mode cull_disabled;

uniform vec4 color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
// √(3)/3 =  0.5773502692
uniform float cosTheta : hint_range(0.0, 1.0) = 0.5773502692;
// 1/(1-√(3)/3) = 2.366025404
uniform float k : hint_range(2.366025404, 20.0) = 7.0;

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
	float facingRatio;
	{
	    vec3 normal = normalize(NORMAL);
	    vec3 brightPole = normalize(vec3(0.0, 0.0, 1.0));
	    float dotProduct = dot(normal, brightPole);
		facingRatio = clamp(dotProduct, 0.0, 1.0);
		// facingRatio = clamp(NORMAL.z, 0.0, 1.0);
	}

	float cosTheta2 = (cosTheta-(NORMAL.x/k));
	//float cosTheta2 = cosTheta;

	ALBEDO = vec3(
		//ModifiedSchlicksBias_Safe(cosTheta, color.r, facingRatio),
		//ModifiedSchlicksBias_Safe(cosTheta, color.r, facingRatio)+(1.0*NORMAL.x/(pow(2.0, 4.0))),
		ModifiedSchlicksBias_Safe(cosTheta2, color.r, facingRatio),
		ModifiedSchlicksBias_Safe(cosTheta2, color.g, facingRatio),
		ModifiedSchlicksBias_Safe(cosTheta2, color.b, facingRatio));

    if (!FRONT_FACING) {
        ALBEDO = vec3(0.0);
    }
}
