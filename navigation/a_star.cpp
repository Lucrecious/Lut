#include "a_star.h"

template <class N, class Hash, class Equal>
std::vector<N> AStar<N, Hash, Equal>::compute(N& start, N& goal) {

	while (!open_set.empty()) {
		N current = *get_minimum_fscore(open_set, fscores);

		if (graph.is_end(current, goal)) {
			return construct_path(came_from, current);
		}

		open_set.erase(current);
		closed_set.insert(current);

		unsigned int size = graph.neighbors(current, buffer);
		for (unsigned int i = 0; i < size; i++) {
			N n = buffer[i];

			if (closed_set.find(n) != closed_set.end()) {
				continue;
			}

			if (open_set.find(n) == open_set.end()) {
				open_set.insert(n);
			}

			unsigned int tmp_gscore = gscores[current] + graph.g(current, n);

			if (gscores.find(n) != gscores.end() && tmp_gscore >= gscores[n]) {
				continue;
			}

			came_from[n] = current;
			gscores[n] = tmp_gscore;
			fscores[n] = tmp_gscore + graph.h(n, goal);
		}
	}

	return 0;
}


