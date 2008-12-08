//
//  TetrisTheme.h
//  Tetris
//
//  Created by Timothy Horton on 2007.11.30.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "tetris.h"

@interface TetrisTheme : NSObject
{
	float gridOpacity;
	int rounded;
	
	NSGradient * background;
	NSGradient * backgroundGlass;
	
	NSColor * gridColor;
	
	NSDictionary * blockColors;
	
	id tetrisView;
}

- (void)setTetrisView:(id)inTetrisView;
- (NSColor *)getColorForType:(gint)inType;
- (NSBezierPath *)createGrid;
- (void)drawBackground:(NSRect)rect;
- (void)drawBlock:(libtetris_block_t *)block atLocation:(NSRect)rect;

- (void)createDefaultTheme;
- (void)createPastelTheme;

@end
