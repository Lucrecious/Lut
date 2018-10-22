#include "a_star.h"
#include "character_graph.h"

#include <cmath>
#include <iostream>

using namespace std;

int main(int cargs, char** args) {
	const int SIZE = 5;
	int _map[SIZE][SIZE] = {
		{0, 0, 0, 0, 0},
		{0, 0, 0, 1, 1},
		{1, 1, 0, 0, 0},
		{0, 0, 0, 0, 0},
		{1, 1, 0, 1, 1}
	};

	int** map = new int*[SIZE];
	for (unsigned int i = 0; i < SIZE; i++) {
		map[i] = new int[SIZE];
		for (unsigned int j = 0; j < SIZE; j++) {
			map[i][j] = _map[i][j];
		}
	}

	CharGraph graph(map, SIZE);
	AStar<CharNode, CharNodeHash, CharNodeEqual> a_star(graph);

	CharNode start;
	start.x = 4; start.y = 0;
	CharNode goal;
	goal.x = 4; goal.y = 3;
	vector<CharNode> path = a_star.compute(goal, start);

	for (unsigned int i = 0; i < path.size(); i++) {
		map[path.at(i).y][path.at(i).x] = 9;
	}

	for (unsigned int i = 0; i < SIZE; i++) {
		for (unsigned int j = 0; j < SIZE; j++) {
			cout << map[i][j] << " ";
		}
		cout << endl;
	}
}





