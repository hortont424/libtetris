/*
 *  tetris.h
 *  TetrisTests
 *
 *  Created by Timothy Horton on 2007.11.20.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _TETRIS_H_
#define _TETRIS_H_

#include <glib.h>
#include <stdlib.h>

#include "blocks.h"
#include "block_operations.h"
#include "block_motion.h"
#include "game.h"

enum { LIBTETRIS_DOWN, LIBTETRIS_LEFT, LIBTETRIS_RIGHT };

#define TILE_WIDTH		10
#define TILE_HEIGHT		20

#endif
