/*
 *  block_operations.h
 *  TetrisTests
 *
 *  Created by Timothy Horton on 2007.11.23.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _BLOCK_OPERATIONS_H_
#define _BLOCK_OPERATIONS_H_

#include <glib.h>
#include <stdlib.h>

#include "blocks.h"
#include "game.h"

libtetris_block_t * libtetris_create_random();

libtetris_block_t * libtetris_initialize_block(gint x, gint y, gint type, gboolean is_center_of_mass);
libtetris_point_t libtetris_initialize_point(gfloat x, gfloat y);

libtetris_block_t * libtetris_interconnect_blocks(libtetris_block_t ** blocks, gint block_count);
gboolean libtetris_connected_blocks(libtetris_block_t * a, libtetris_block_t * b);
void libtetris_disconnect_block(libtetris_game_t * game, libtetris_block_t * block);

libtetris_block_t * libtetris_copy_block(libtetris_block_t * block);

libtetris_point_t libtetris_center_of_mass(libtetris_block_t * block);

void libtetris_delete_block(libtetris_block_t * block);

#endif
