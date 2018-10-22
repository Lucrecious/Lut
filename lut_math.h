#ifndef MATH_H
#define MATH_H

#include <cmath> 

int round_to(int num, int div) {
	return std::round(num/div)*div;
}

int ceil_to(int num, int div) {
	return std::ceil(num/div)*div;
}

int floor_to(int num, int div) {
	return std::floor(num/div)*div;
}


#endif