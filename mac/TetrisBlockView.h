//
//  TetrisBlockView.h
//  TetrisTests
//
//  Created by Timothy Horton on 2007.11.21.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "tetris.h"
#import "TetrisTheme.h"

@interface TetrisBlockView : NSView
{
	libtetris_block_t * block;
	TetrisTheme * theme;
}

- (void)setBlock:(libtetris_block_t *)inBlock;
- (libtetris_block_t *)block;

- (void)setTheme:(TetrisTheme *)inTheme;
- (TetrisTheme *)theme;

@end
