/*
 *  block_operations.c
 *  TetrisTests
 *
 *  Created by Timothy Horton on 2007.11.23.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include "block_operations.h"
#include "game.h"

/* allocate memory and initialize variables for a point */
libtetris_point_t libtetris_initialize_point(gfloat x,
											 gfloat y)
{
	libtetris_point_t point;
	point.x = x;
	point.y = y;
	return point;
}

/* allocate memory and initialize variables for a single block */
libtetris_block_t * libtetris_initialize_block(gint x,
											   gint y,
											   gint type,
											   gboolean center_of_mass)
{
	libtetris_block_t * block = malloc(sizeof(libtetris_block_t));
	
	block->x = x;
	block->y = y;
	
	block->connections = NULL;
	
	block->type = type;
	block->center_of_mass = center_of_mass;
	
	return block;
}

/* given an array of blocks, and its length, put every block in
   every block's list of connections, including itself */
libtetris_block_t * libtetris_interconnect_blocks(libtetris_block_t ** blocks,
												  gint block_count)
{
	for(gint i = 0; i < block_count; i++)
		for(gint j = 0; j < block_count; j++)
			blocks[i]->connections = g_list_prepend(blocks[i]->connections,
													blocks[j]);
	
	return blocks[0];
}

/* remove a block from all of its neighbors and from the game board */
void libtetris_disconnect_block(libtetris_game_t * game, libtetris_block_t * block)
{
	if(!block || !game)
		return;
	
	for(gint i = 0; i < g_list_length(block->connections); i++)
	{
		libtetris_block_t * nextBlock = ((libtetris_block_t *)g_list_nth_data(block->connections, i));
		
		if(nextBlock && nextBlock->connections)
		{
			nextBlock->connections = g_list_remove(nextBlock->connections, block);
		}
	}
	
	g_list_free(block->connections);
	block->connections = NULL;
	
	game->blocks = g_list_remove(game->blocks,block);
}


/* create a random block */
libtetris_block_t * libtetris_create_random()
{
	switch(g_random_int_range(1,8))
	{
		case 1: return libtetris_create_I(3,20);
		case 2: return libtetris_create_J(3,20);
		case 3: return libtetris_create_L(3,20);
		case 4: return libtetris_create_O(3,20);
		case 5: return libtetris_create_S(3,20);
		case 6: return libtetris_create_T(3,20);
		case 7: return libtetris_create_Z(3,20);
	}
}

/* create a copy of a block and all the blocks it connects to */
libtetris_block_t * libtetris_copy_block(libtetris_block_t * block)
{
	libtetris_block_t * newBlocks[g_list_length(block->connections) + 2];
		
	for(guint i = 0; i < g_list_length(block->connections); i++)
	{
		libtetris_block_t * tetris_block = ((libtetris_block_t *)g_list_nth_data(block->connections, i));
		
		newBlocks[i] = libtetris_initialize_block(tetris_block->x, tetris_block->y, tetris_block->type, tetris_block->center_of_mass);
	}
	
	return libtetris_interconnect_blocks(newBlocks, g_list_length(block->connections));
}

/* returns whether or not two blocks are connected */
gboolean libtetris_connected_blocks(libtetris_block_t * a, libtetris_block_t * b)
{
	if(a == b)
		return TRUE;
	
	for(guint i = 0; i < g_list_length(a->connections); i++)
		if(g_list_nth_data(a->connections, i) == b)
			return TRUE;
	
	return FALSE;
}

/* calculate the location of the center of mass of a system of blocks.
   the O is a special case because we want it to rotate around its center
   instead of the actual, though false, standard tetris center-of-mass */
libtetris_point_t libtetris_center_of_mass(libtetris_block_t * block)
{
	if(!block)
		return libtetris_initialize_point(0,0);
	
	if(block->type == TETRIS_O)
	{
		gfloat avgx = 0.0, avgy = 0.0;
		for(int i = 0; i < g_list_length(block->connections); i++)
		{
			libtetris_block_t * tetris_block = ((libtetris_block_t *)g_list_nth_data(block->connections, i));
			avgx += tetris_block->x;
			avgy += tetris_block->y;
		}
		
		return libtetris_initialize_point(avgx/4, avgy/4);
	}
	
	for(int i = 0; i < g_list_length(block->connections); i++)
	{
		libtetris_block_t * tetris_block = ((libtetris_block_t *)g_list_nth_data(block->connections, i));
		
		if(tetris_block->center_of_mass)
			return libtetris_initialize_point(tetris_block->x, tetris_block->y);
	}
	
	return libtetris_initialize_point(0,0);
}

void libtetris_delete_block(libtetris_block_t * block)
{
	if(block->connections)
		g_list_free(block->connections);
	
	block->connections = NULL;
	free(block);
}
