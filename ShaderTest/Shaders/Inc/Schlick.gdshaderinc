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

	// 1. Most common case: Both inputs are within the standard range.
	// Check this first to skip all edge-case logic for the majority of pixels.
	if (a > 0.0 && a < 1.0 && b > 0.0 && b < 1.0) {
		return ModifiedSchlicksBias(a, b, x);
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
	// Effectively covers the remaining scenarios:
	// - b == 0 (and a != 0)
	// - a == 1 (and b != 1)
	return 0.0;
}

#endif
