/*
 *  blocks.c
 *  TetrisTests
 *
 *  Created by Timothy Horton on 2007.11.23.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include "blocks.h"
#include "block_operations.h"

libtetris_block_t * libtetris_create_I(gint x, gint y)
{
	libtetris_block_t * blocks[] =
	{
		libtetris_initialize_block(x, y, TETRIS_I, FALSE),
		libtetris_initialize_block(x + 1, y, TETRIS_I, TRUE),
		libtetris_initialize_block(x + 2, y, TETRIS_I, FALSE),
		libtetris_initialize_block(x + 3, y, TETRIS_I, FALSE)
	};
	
	return libtetris_interconnect_blocks(blocks, 4);
}

libtetris_block_t * libtetris_create_J(gint x, gint y)
{
	libtetris_block_t * blocks[] =
	{
		libtetris_initialize_block(x, y, TETRIS_J, FALSE),
		libtetris_initialize_block(x, y + 1, TETRIS_J, FALSE),
		libtetris_initialize_block(x + 1, y, TETRIS_J, TRUE),
		libtetris_initialize_block(x + 2, y, TETRIS_J, FALSE)
	};
	
	return libtetris_interconnect_blocks(blocks, 4);
}

libtetris_block_t * libtetris_create_L(gint x, gint y)
{
	libtetris_block_t * blocks[] =
	{
		libtetris_initialize_block(x, y, TETRIS_L, FALSE),
		libtetris_initialize_block(x + 1, y, TETRIS_L, TRUE),
		libtetris_initialize_block(x + 2, y, TETRIS_L, FALSE),
		libtetris_initialize_block(x + 2, y + 1, TETRIS_L, FALSE)
	};
	
	return libtetris_interconnect_blocks(blocks, 4);
}

libtetris_block_t * libtetris_create_O(gint x, gint y)
{
	libtetris_block_t * blocks[] =
	{
		libtetris_initialize_block(x, y, TETRIS_O, FALSE),
		libtetris_initialize_block(x, y + 1, TETRIS_O, FALSE),
		libtetris_initialize_block(x + 1, y + 1, TETRIS_O, FALSE),
		libtetris_initialize_block(x + 1, y, TETRIS_O, FALSE)
	};
	
	return libtetris_interconnect_blocks(blocks, 4);
}

libtetris_block_t * libtetris_create_S(gint x, gint y)
{
	libtetris_block_t * blocks[] =
	{
		libtetris_initialize_block(x, y, TETRIS_S, FALSE),
		libtetris_initialize_block(x + 1, y, TETRIS_S, TRUE),
		libtetris_initialize_block(x + 1, y + 1, TETRIS_S, FALSE),
		libtetris_initialize_block(x + 2, y + 1, TETRIS_S, FALSE)
	};
	
	return libtetris_interconnect_blocks(blocks, 4);
}

libtetris_block_t * libtetris_create_T(gint x, gint y)
{
	libtetris_block_t * blocks[] =
	{
		libtetris_initialize_block(x, y, TETRIS_T, FALSE),
		libtetris_initialize_block(x + 1, y, TETRIS_T, TRUE),
		libtetris_initialize_block(x + 1, y + 1, TETRIS_T, FALSE),
		libtetris_initialize_block(x + 2, y, TETRIS_T, FALSE)
	};
	
	return libtetris_interconnect_blocks(blocks, 4);
}

libtetris_block_t * libtetris_create_Z(gint x, gint y)
{
	libtetris_block_t * blocks[] =
	{
		libtetris_initialize_block(x, y + 1, TETRIS_Z, FALSE),
		libtetris_initialize_block(x + 1, y + 1, TETRIS_Z, FALSE),
		libtetris_initialize_block(x + 1, y, TETRIS_Z, TRUE),
		libtetris_initialize_block(x + 2, y, TETRIS_Z, FALSE)
	};
	
	return libtetris_interconnect_blocks(blocks, 4);
}