//
//  TetrisBlockView.m
//  TetrisTests
//
//  Created by Timothy Horton on 2007.11.21.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TetrisBlockView.h"


@implementation TetrisBlockView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (void)drawRect:(NSRect)rect
{
	[theme drawBlock:block atLocation:rect];
}

- (void)setBlock:(libtetris_block_t *)inBlock
{
	block = inBlock;
}

- (libtetris_block_t *)block
{
	return block;
}

- (void)setTheme:(TetrisTheme *)inTheme
{
	theme = inTheme;
}

- (TetrisTheme *)theme
{
	return theme;
}

@end
