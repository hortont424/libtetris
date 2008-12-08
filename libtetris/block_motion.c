/*
 *  block_motion.c
 *  TetrisTests
 *
 *  Created by Timothy Horton on 2007.11.23.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include "block_motion.h"
#include "block_operations.h"

gboolean libtetris_move_block(libtetris_game_t * game, libtetris_block_t * block, gint direction)
{
	if(!block)
		return FALSE;
	
	gint dx = 0, dy = 0;
	
	switch(direction)
	{
		case LIBTETRIS_LEFT:	dx = -1;	dy = +0;	break;
		case LIBTETRIS_RIGHT:	dx = +1;	dy = +0;	break;
		case LIBTETRIS_DOWN:	dx = +0;	dy = -1;	break;
		default:				dx = +0;	dy = +0;	break;
	}
	
	libtetris_block_t * testBlock = libtetris_copy_block(block);
	
	// perform translation on copy of blocks
	for(int i = 0; i < g_list_length(testBlock->connections); i++)
	{
		((libtetris_block_t *)g_list_nth_data(testBlock->connections, i))->x += dx;
		((libtetris_block_t *)g_list_nth_data(testBlock->connections, i))->y += dy;
	}
	
	// check if translation is acceptable
	if(!moveIsAcceptable(testBlock, block, game))
		return FALSE;
	
	// perform translation on actual blocks
	for(int i = 0; i < g_list_length(block->connections); i++)
	{
		((libtetris_block_t *)g_list_nth_data(block->connections, i))->x += dx;
		((libtetris_block_t *)g_list_nth_data(block->connections, i))->y += dy;
	}
	
	return TRUE;
}

gboolean libtetris_rotate_block(libtetris_game_t * game, libtetris_block_t * block)
{
	if(!block)
		return FALSE;
	
	libtetris_block_t * testBlock = libtetris_copy_block(block);
	
	libtetris_point_t center_of_mass = libtetris_center_of_mass(testBlock);
	
	// perform rotation on copy of blocks
	for(int i = 0; i < g_list_length(testBlock->connections); i++)
	{
		libtetris_block_t * nextBlock = ((libtetris_block_t *)g_list_nth_data(testBlock->connections, i));
		
		float nx = center_of_mass.x - (center_of_mass.y - ((float) nextBlock->y));
		float ny = center_of_mass.y + (center_of_mass.x - ((float) nextBlock->x));
		
		nextBlock->x = nx;
		nextBlock->y = ny;
	}
	
	// check if rotation is acceptable
	if(!moveIsAcceptable(testBlock, block, game))
		return FALSE;
	
	// perform rotation on actual blocks
	for(int i = 0; i < g_list_length(block->connections); i++)
	{
		libtetris_block_t * nextBlock = ((libtetris_block_t *)g_list_nth_data(block->connections, i));
		
		float nx = center_of_mass.x - (center_of_mass.y - ((float) nextBlock->y));
		float ny = center_of_mass.y + (center_of_mass.x - ((float) nextBlock->x));
		
		nextBlock->x = nx;
		nextBlock->y = ny;
	}
}

gboolean moveIsAcceptable(libtetris_block_t * newBlock, libtetris_block_t * block, libtetris_game_t * game)
{
	for(int i = 0; i < g_list_length(newBlock->connections); i++)
	{
		libtetris_block_t * tetris_block = (libtetris_block_t *)g_list_nth_data(newBlock->connections, i);
		libtetris_block_t * ingame_block = libtetris_block_at_location(game, libtetris_initialize_point(tetris_block->x, tetris_block->y));
		
		if(tetris_block->y < 0 || tetris_block->x < 0 || tetris_block->x >= TILE_WIDTH)
			return FALSE;
		
		if(ingame_block != NULL && !libtetris_connected_blocks(ingame_block, block))
			return FALSE;
	}
	
	return TRUE;
}