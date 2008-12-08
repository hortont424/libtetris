//
//  TetrisTheme.m
//  Tetris
//
//  Created by Timothy Horton on 2007.11.30.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TetrisTheme.h"
#import "TetrisBlockView.h"

@implementation TetrisTheme

- (id) init
{
	self = [super init];
	
	if (self != nil)
	{
		[self createDefaultTheme];
		//[self createPastelTheme];
	}
	
	return self;
}

- (void)createDefaultTheme
{
	NSArray * keys = [NSArray arrayWithObjects:	[NSNumber numberWithInt:TETRIS_I],
												[NSNumber numberWithInt:TETRIS_J],
												[NSNumber numberWithInt:TETRIS_L],
												[NSNumber numberWithInt:TETRIS_O],
												[NSNumber numberWithInt:TETRIS_S],
												[NSNumber numberWithInt:TETRIS_T],
												[NSNumber numberWithInt:TETRIS_Z], nil];
	
	NSArray * objects = [NSArray arrayWithObjects:	[NSColor cyanColor],
													[NSColor blueColor],
													[NSColor orangeColor],
													[NSColor yellowColor],
													[NSColor greenColor],
													[NSColor purpleColor],
													[NSColor redColor], nil];
	
	blockColors = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
	
	gridOpacity = .05;
	gridColor = [NSColor blackColor];
	
	background = [[NSGradient alloc] initWithStartingColor:[[NSColor whiteColor] colorWithAlphaComponent:1.0] endingColor:[NSColor whiteColor]];
	backgroundGlass = nil;
	rounded = 4;
}

- (void)createPastelTheme
{
	NSArray * keys = [NSArray arrayWithObjects:	[NSNumber numberWithInt:TETRIS_I],
												[NSNumber numberWithInt:TETRIS_J],
												[NSNumber numberWithInt:TETRIS_L],
												[NSNumber numberWithInt:TETRIS_O],
												[NSNumber numberWithInt:TETRIS_S],
												[NSNumber numberWithInt:TETRIS_T],
												[NSNumber numberWithInt:TETRIS_Z], nil];
	
	NSArray * objects = [NSArray arrayWithObjects:	[NSColor colorWithCalibratedRed:0.671 green:0.858 blue:0.941 alpha:1.0],		// cyan
													[NSColor colorWithCalibratedRed:0.436 green:0.608 blue:0.848 alpha:1.0],		// blue
													[NSColor colorWithCalibratedRed:0.960 green:0.800 blue:0.650 alpha:1.0],		// orange
													[NSColor colorWithCalibratedRed:0.986 green:0.966 blue:0.518 alpha:1.0],		// yellow
													[NSColor colorWithCalibratedRed:0.804 green:0.946 blue:0.666 alpha:1.0],		// green
													[NSColor colorWithCalibratedRed:0.652 green:0.565 blue:0.812 alpha:1.0],		// purple
													[NSColor colorWithCalibratedRed:0.978 green:0.826 blue:0.896 alpha:1.0], nil];	// red
	
	blockColors = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
	
	gridOpacity = .05;
	gridColor = [NSColor blackColor];
	
	background = [[NSGradient alloc] initWithStartingColor:[[NSColor blackColor] colorWithAlphaComponent:1.0] endingColor:[NSColor whiteColor]];
	backgroundGlass = [[NSGradient alloc] initWithStartingColor:[[NSColor whiteColor] colorWithAlphaComponent:0.9] endingColor:[[NSColor whiteColor] colorWithAlphaComponent:0.0]];
	rounded = 6;
}

- (NSColor *)getColorForType:(gint)inType
{
	return [blockColors objectForKey:[NSNumber numberWithInt:inType]];
}

- (NSBezierPath *)createGrid
{
	NSBezierPath * grid = [[NSBezierPath alloc] init];
	
	for(float x = 0; x < [tetrisView frame].size.width; x += ([tetrisView frame].size.width / TILE_WIDTH))
	{
		[grid moveToPoint:NSMakePoint(x,0)];
		[grid lineToPoint:NSMakePoint(x,[tetrisView frame].size.height)];
	}
	
	for(float y = 0; y < [tetrisView frame].size.height; y += ([tetrisView frame].size.height / TILE_HEIGHT))
	{
		[grid moveToPoint:NSMakePoint(0,y)];
		[grid lineToPoint:NSMakePoint([tetrisView frame].size.width,y)];
	}
	
	return grid;
}

- (void)drawBackground:(NSRect)rect
{
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	[[NSBezierPath bezierPathWithRoundedRect:rect xRadius:rounded*([tetrisView frame].size.width / 200) yRadius:rounded*([tetrisView frame].size.width / 200)] setClip];
	
	[background drawInRect:rect angle:270.0];
	
	[[gridColor colorWithAlphaComponent:gridOpacity] setStroke];
	[[self createGrid] stroke];
	
	if(backgroundGlass != nil)
	{
		[[NSGraphicsContext currentContext] saveGraphicsState];
		[[NSBezierPath bezierPathWithRoundedRect:NSOffsetRect(NSInsetRect(rect,-10,-10), 0, -10) xRadius:20 yRadius:20] setClip];
		[backgroundGlass drawInRect:rect angle:270.0];
		[[NSGraphicsContext currentContext] restoreGraphicsState];
	}
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawBlock:(libtetris_block_t *)block atLocation:(NSRect)rect
{
	NSRect blockRect = rect;
	
	NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(blockRect,1,1) xRadius:rounded*([tetrisView frame].size.width / 200) yRadius:rounded*([tetrisView frame].size.width / 200)];
	
	[[self getColorForType:block->type] setFill];
	[path fill];
	
	[[[NSColor blackColor] colorWithAlphaComponent:0.75] setStroke];
	[path stroke];
	
	NSGradient * grad = [[NSGradient alloc] initWithStartingColor:[[NSColor whiteColor] colorWithAlphaComponent:0.7] endingColor:[[NSColor whiteColor] colorWithAlphaComponent:0.0]];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[[NSBezierPath bezierPathWithRoundedRect:NSOffsetRect(NSInsetRect(blockRect,3,3),0,1) xRadius:rounded*([tetrisView frame].size.width / 200) yRadius:rounded*([tetrisView frame].size.width / 200)] setClip];
	[grad drawInRect:NSOffsetRect(NSInsetRect(blockRect,3,3),0,2) angle:270.0];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	
	[grad release];
}

- (void)setTetrisView:(id)inTetrisView
{
	tetrisView = inTetrisView;
}


@end
