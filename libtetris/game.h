/*
 *  board.h
 *  TetrisTests
 *
 *  Created by Timothy Horton on 2007.11.23.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_H_
#define _GAME_H_

#include <glib.h>
#include <stdlib.h>

#include "blocks.h"

typedef struct libtetris_game
{
	GList * blocks;
	gint score;
	gint level;
} libtetris_game_t;

libtetris_game_t * libtetris_create_game();
libtetris_block_t * libtetris_block_at_location(libtetris_game_t * game, libtetris_point_t point);
void libtetris_drop_all_above(libtetris_game_t * game, gint row);
gboolean libtetris_update_score(libtetris_game_t * game, gint lines_cleared);

#endif