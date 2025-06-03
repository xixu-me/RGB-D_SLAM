#pragma once

#include <DS.h>

AssociateList readAssociationFile(const string &fileName);

// Remove elements at even indices from vector
template <typename T>
void removeIndexElements(vector<T> &vec) {
	size_t j = 0;
	for (size_t i = 0; i < vec.size(); ++i) {
		if (i % 2 != 0) { // Keep element only when index i is odd
			vec[j] = vec[i];
			++j;
		}
	}
	vec.resize(j); // Resize vector to remove excess elements at the end
}