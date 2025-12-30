#ifndef SCHLICK_INC
#define SCHLICK_INC

float ModifiedSchlicksBias(float a, float b, float x) {
	float c1 = b * (1.0 - a);
	float c2 = b - a;
	float c3 = a * (1.0 - b);
	return (c1 * x) / (c2 * x + c3);
}

/*
	Unoptimized logic for ModifiedSchlicksBias_Safe:

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
*/
float ModifiedSchlicksBias_Safe(float a, float b, float x) {
	a = clamp(a, 0.0, 1.0);
	b = clamp(b, 0.0, 1.0);
	x = clamp(x, 0.0, 1.0);

	// 1. Most common case: Both inputs are within the standard range.
	// Check this first to skip all edge-case logic for the majority of pixels.
	if (a > 0.0 && a < 1.0 && b > 0.0 && b < 1.0) {
		return clamp(ModifiedSchlicksBias(a, b, x), 0.0, 1.0);
	}

	// 2. Pass-through cases: (0,0) and (1,1)
	//
	// a. Rearrange the boolean condition from step 1 using De Morgan's Law:
	//     !((a >  0.0) &&  (a <  1.0)  &&   (b >  0.0)   &&  (b  < 1.0))
	//      !(a >  0.0) || !(a <  1.0)  || ! (b >  0.0)   || !(b  < 1.0)
	//       (a <= 0.0) ||  (a >= 1.0)  ||   (b <= 0.0)   ||  (b >= 1.0)
	// b. Observe the following is true since a and b are clamped:
	//     (a >= 0.0) && (a <= 1.0) && (b >= 0.0) && (b <= 1.0)
	// c. AND those results, which implies:
	//     (a == 0.0) || (a == 1.0) || (b == 0.0) || (b == 1.0)
	// d. AND that result with (a == b), which implies:
	//     ((a == 0.0) && (b == 0.0)) || ((a == 1.0) && (b == 1.0))
	//
	// When a and b are both 0 or 1, the result is x.
	if (a == b) {
		return x;
	}

	// 3. Return 1.0 cases:
	// - a == 0 (and b != 0, since a==b check failed)
	// - b == 1 (and a != 1, since a==b check failed)
	if (a == 0.0 || b == 1.0) {
		return 1.0;
	}

	// 4. Return 0.0 cases:
	// - b == 0 (and a != 0)
	// - a == 1 (and b != 1)
	if (a == 1.0 || b == 0.0) {
		return 0.0;
	}

	// This doesn't handle a defined case.
	return 0.0;
}

float Schlick2_Raw(float a, float b, float c, float d, float x) {
	float k1 = d * (b - c) - a * b * (d - c);
	float k2 = a * c * (d - b);
	float k3 = (b - c) - a * (d - c);
	float k4 = a * (d - b);
	return (k1 * x + k2) / (k3 * x + k4);
}

float Schlick2(float a, float b, float c, float d, float x) {
	a = clamp(a, 0.0, 1.0);
	b = clamp(b, 0.0, 1.0);
	c = clamp(c, 0.0, 1.0);
	d = clamp(d, 0.0, 1.0);
	x = clamp(x, 0.0, 1.0);

	// TODO: Review/prove the below Gemini-generated code for soundness.

	// 1. Common case: Both inputs are within the standard range.
	if (a > 0.0 && a < 1.0 && b != c && b != d) {
		return clamp(Schlick2_Raw(a, b, c, d, x), 0.0, 1.0);
	}

	// 2. Linear cases: (a=0, b=c) or (a=1, b=d)
	if ((a == 0.0 && b == c) || (a == 1.0 && b == d)) {
		return clamp(mix(c, d, x), 0.0, 1.0);
	}

	// 3. Constant d cases:
	if (b == d || a == 0.0) {
		return d;
	}

	// 4. Constant c cases:
	if (b == c || a == 1.0) {
		return c;
	}

	// This doesn't handle a defined case.
	return 0.0;
}

#endif
