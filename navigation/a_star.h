#ifndef A_STAR_H
#define A_STAR_H

#include <limits>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#define MAX_NEIGHBORS 10

template<class N>
class Graph {
public:
	virtual bool is_end(N& node, N& goal) = 0;
	virtual unsigned int neighbors(N&, N* buffer) = 0;
	virtual unsigned int g(N& from, N& to) = 0;
	virtual unsigned int h(N& from, N& to) = 0;

	virtual ~Graph() {}
};

template <class N, class Hash, class Equal>
class AStar {
private:
	Graph<N>& graph;

	N get_minimum_fscore(
		std::unordered_set<N, Hash, Equal> open_set,
		std::unordered_map<N, unsigned int, Hash, Equal> fscores) {
		unsigned int m = UINT_MAX;
		N out;

		for (typename std::unordered_set<N, Hash, Equal>::iterator it = open_set.begin();
				it != open_set.end(); ++it) {
			unsigned int fscore = fscores[*it];
			if (fscore < m) {
				m = fscore;
				out = *it;
			}
		}

		return out;
	}

	std::vector<N> construct_path(std::unordered_map<N, N, Hash, Equal> came_from, N& current) {
		std::vector<N> path;
		path.push_back(current);
		while (came_from.find(current) != came_from.end()) {
			current = came_from[current];
			path.push_back(current);
		}

		return path;
	}

	
public:
	std::vector<N> compute(N& start, N& goal) {
		N buffer[MAX_NEIGHBORS];

		std::unordered_set<N, Hash, Equal> open_set;
		open_set.insert(start);

		std::unordered_set<N, Hash, Equal> closed_set;
		std::unordered_map<N, N, Hash, Equal> came_from;
		std::unordered_map<N, unsigned int, Hash, Equal> gscores;
		std::unordered_map<N, unsigned int, Hash, Equal> fscores;

		while (!open_set.empty()) {
			N current = get_minimum_fscore(open_set, fscores);

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

		std::vector<N> v;
		return v;
	}

	AStar(Graph<N>& graph) : graph(graph) {
	}

	virtual ~AStar() {}
};

#endif