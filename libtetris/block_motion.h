/*
 *  block_motion.h
 *  TetrisTests
 *
 *  Created by Timothy Horton on 2007.11.23.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _BLOCK_MOTION_H_
#define _BLOCK_MOTION_H_

#include <glib.h>
#include <stdlib.h>

#include "blocks.h"
#include "game.h"
#include "tetris.h"

#define TILE_WIDTH		10
#define TILE_HEIGHT		20

gboolean libtetris_move_block(libtetris_game_t * game, libtetris_block_t * block, gint direction);

gboolean libtetris_rotate_block(libtetris_game_t * game, libtetris_block_t * block);

gboolean moveIsAcceptable(libtetris_block_t * newBlock, libtetris_block_t * block, libtetris_game_t * game);

#endif