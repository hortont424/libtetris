/*
 *  blocks.h
 *  TetrisTests
 *
 *  Created by Timothy Horton on 2007.11.23.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _BLOCKS_H_
#define _BLOCKS_H_

#include <glib.h>
#include <stdlib.h>

typedef struct libtetris_block
{
	GList * connections;
	gint x, y;
	gint type;
	gboolean center_of_mass;
} libtetris_block_t;

typedef struct libtetris_point
{
	gfloat x, y;
} libtetris_point_t;

enum { TETRIS_I, TETRIS_J, TETRIS_L, TETRIS_S, TETRIS_Z, TETRIS_T, TETRIS_O };

libtetris_block_t * libtetris_create_I(gint x, gint y);
libtetris_block_t * libtetris_create_J(gint x, gint y);
libtetris_block_t * libtetris_create_L(gint x, gint y);
libtetris_block_t * libtetris_create_O(gint x, gint y);
libtetris_block_t * libtetris_create_S(gint x, gint y);
libtetris_block_t * libtetris_create_T(gint x, gint y);
libtetris_block_t * libtetris_create_Z(gint x, gint y);

#endif
