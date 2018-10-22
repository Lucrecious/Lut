#include "character_graph.h"
#include "../lut_math.h"

unsigned int CharGraph::neighbors(CharNode& cur, CharNode* buffer) {
	unsigned int buffern = 0;

	CharNode neighbors[MAX_DIR];
	unsigned int neighborsn = possible_neighbors(cur, neighbors);

	bool on_ground;
	bool on_climb;
	bool at_ceiling;

	int max_jump_height = jump_height * air_vel_rate;
	int avr = air_vel_rate;

	for (unsigned int i = 0; i < neighborsn; i++) {
		CharNode n = neighbors[i];

		if (is_collision(n)) continue;
		if (!can_fit(n)) continue;

		on_ground = this->on_ground(n);
		on_climb = this->on_climb(n);
		at_ceiling = this->at_ceiling(n);

		// calculating the jump
		int jump_length = cur.jump;
		int new_jump_length = jump_length;
		int ar = jump_length % avr;

		if (on_ground || on_climb) {
			new_jump_length = 0;
		} else if (at_ceiling) {
			if (cur.x != n.x) {
				new_jump_length = std::max(max_jump_height + 1, jump_length + 1);
			} else {
				new_jump_length = std::max(max_jump_height, jump_length + avr);
			}
		} else if (n.y < cur.y) {
			if (jump_length < 2) {
				new_jump_length = avr * 2 - 1;
			} else {
				new_jump_length = ceil_to(jump_length + 1, avr);
			}
			/*
			elif (ar == 0) {
				new_jump_length = jump_length + avr;
			} else {
				new_jump_length = jump_length + avr + 1;
			}
			*/
		} else if (n.y > cur.y) {
			int next_jump = ceil_to(jump_length + 1, avr);
			if (ar == 0) {
				new_jump_length = std::max(max_jump_height, next_jump);
			} else {
				new_jump_length = std::max(max_jump_height + 1, next_jump);
			}
		} else if ((!on_ground || !on_climb) && n.x != cur.x) {
			if (cur.type == TileType_Climb) {
				new_jump_length = max_jump_height + 1;
			} else {
				new_jump_length = jump_length + 1;
			}
		}

		// validation 

		// can't move left/right during jump on odd number
		if (ar != 0 && cur.x != n.x) continue;

		// only fall after max jump height reached
		if (jump_length >= max_jump_height && n.y < cur.y) continue;

		// start only being able to move down after some threshold
		if (new_jump_length >= max_jump_height + 6 && n.x != cur.x
			&& (new_jump_length - (max_jump_height + 6)) % 8 != 3) continue;

		n.jump = new_jump_length;
		buffer[buffern++] = n;
	}

	return buffern;
}

unsigned int CharGraph::possible_neighbors(CharNode& node, CharNode* buffer) {
	unsigned int neighborsn = 0;
	int directions[2] = {-1, 1};
	bool on_ys[2] = {true, false};

	int x;
	int y;
	CharNode tmp;
	for (unsigned int i = 0; i < 2; i++) {
		int dir = directions[i];
		for (unsigned int j = 0; j < 2; j++) {
			bool on_y = on_ys[j];
			x = on_y ? node.x : node.x + dir;
			y = on_y ? node.y + dir : node.y;

			if (!tile_to_node(x, y, tmp)) {
				continue;
			}

			buffer[neighborsn++] = tmp;
		}
	}

	return neighborsn;
}

bool CharGraph::is_collision(CharNode& node) {
	return node.type == TileType_Ground;
}

bool CharGraph::can_fit(CharNode& node) {
	return true;
}

bool CharGraph::on_ground(CharNode& node) {
	CharNode node_below;
	if (!tile_to_node(node.x, node.y + 1, node_below)) {
		return false;
	}
	return node_below.type == TileType_Ground
		|| (node_below.type == TileType_Climb && node.type == TileType_Air);
}

bool CharGraph::on_climb(CharNode& node) {
	return node.type == TileType_Climb;
}

bool CharGraph::at_ceiling(CharNode& node) {
	CharNode node_above;
	if (!tile_to_node(node.x, node.y - 1, node_above)) {
		return false;
	}

	return node_above.type == TileType_Ground;
}

bool CharGraph::tile_to_node(int x, int y, CharNode& node) {
	if (x < 0 || x >= size || y < 0 || y >= size) {
		return false;
	}

	node.x = x;
	node.y = y;
	node.jump = 0;
	node.type = tile_type(x, y);

	return true;
}

TileType CharGraph::tile_type(int x, int y) {
	return (TileType)map[y][x];
}
















