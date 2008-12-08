/*
 *  board.c
 *  TetrisTests
 *
 *  Created by Timothy Horton on 2007.11.23.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include "game.h"

libtetris_game_t * libtetris_create_game()
{
	libtetris_game_t * game = malloc(sizeof(libtetris_game_t));
	game->blocks = NULL;
	game->score = 0;
	game->level = 1;
	return game;
}

libtetris_block_t * libtetris_block_at_location(libtetris_game_t * game, libtetris_point_t point)
{
	for(gint i = 0; i < g_list_length(game->blocks); i++)
	{
		libtetris_block_t * tetris_block = (libtetris_block_t *)g_list_nth_data(game->blocks, i);
		
		if(tetris_block->x >= point.x && tetris_block->y >= point.y && tetris_block->x < point.x + 1 && tetris_block->y < point.y + 1)
			return tetris_block;
	}
	
	return NULL;
}

void libtetris_drop_all_above(libtetris_game_t * game, gint row)
{	
	for(gint j = g_list_length(game->blocks) - 1; j >= 0 ; j--)
	{
		libtetris_block_t * tetris_block = ((libtetris_block_t *)g_list_nth_data(game->blocks, j));
		
		if(tetris_block->y > row)
			tetris_block->y--;
	}
}

gboolean libtetris_update_score(libtetris_game_t * game, gint lines_cleared)
{
	switch(lines_cleared)
	{
		case 0:
			return FALSE;
		case 1:
			game->score += game->level * 40;
			break;
		case 2:
			game->score += game->level * 100;
			break;
		case 3:
			game->score += game->level * 300;
			break;
		case 4:
			game->score += game->level * 1200;
			break;
		default:
			break;
	}
	
	return TRUE;
}