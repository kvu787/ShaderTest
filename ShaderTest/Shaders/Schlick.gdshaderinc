#ifndef SCHLICK_INC
#define SCHLICK_INC

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

#endif
