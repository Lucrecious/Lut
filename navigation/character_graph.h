#ifndef CHARACTER_GRAPH_H
#define CHARACTER_GRAPH_H

#include "a_star.h"

#include <algorithm>
#include <stdlib.h>

#define MAX_DIR 4

enum TileType {
	TileType_Air = 0,
	TileType_Ground = 1,
	TileType_Climb = 2,
};

struct CharNode {
	int x;
	int y;
	int jump;
	TileType type;

	CharNode() : x(0), y(0), jump(0), type(TileType_Air) {}

	CharNode(const CharNode& other) : 
		x(other.x), y(other.y), jump(other.jump), type(other.type) {}

	CharNode& operator=(const CharNode& other) {
		if (this != &other) {
			x = other.x;
			y = other.y;
			jump = other.jump;
			type = other.type;
		}

		return *this;
	}
};

struct CharNodeEqual {
	bool operator()(const CharNode& n1, const CharNode& n2) const {
		return n1.x == n2.x &&
				n1.y == n2.y &&
				n1.jump == n2.jump &&
				n1.type == n2.type;
	}
};

struct CharNodeHash {
	bool operator()(const CharNode& n) const {
		return std::hash<int>()(n.x + n.y + n.jump + (int)n.type);
	}
};

class CharGraph : public Graph<CharNode> {
public:
	bool is_end(CharNode& node, CharNode& goal) {
		return node.x == goal.x & node.y == goal.y;
	}

	unsigned int g(CharNode& from, CharNode& to) {
		return 1 + to.jump / 4;
	}

	unsigned int h(CharNode& from, CharNode& to) {
		return abs(to.x - from.x) + abs(to.y - from.y);
	}

	unsigned int neighbors(CharNode& node, CharNode* buffer);

	CharGraph(int** map, unsigned int size) : map(map), size(size) {}

	int jump_height = 3;
	int air_vel_rate = 5;

private:
	int** map;
	unsigned int size;

	bool is_collision(CharNode& node);
	bool can_fit(CharNode& node);
	bool on_ground(CharNode& node);
	bool on_climb(CharNode& node);
	bool at_ceiling(CharNode& node);
	unsigned int possible_neighbors(CharNode& node, CharNode* buffer);

	bool tile_to_node(int x, int y, CharNode& node);
	TileType tile_type(int x, int y);
};











#endif