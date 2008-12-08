//
//  TetrisView.m
//  TetrisTests
//
//  Created by Timothy Horton on 2007.11.20.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TetrisView.h"
#import "QuartzCore/CAAnimation.h"

@implementation TetrisView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)drawRect:(NSRect)rect
{
	[theme drawBackground:rect];
}

- (void)explodeRow:(int)row
{	
	for (TetrisBlockView * v in [self subviews])
	{
		libtetris_block_t * block = [v block];
		
		if(block->y == row)
		{
			[NSAnimationContext beginGrouping];
			[[NSAnimationContext currentContext] setDuration:0.5f];
			
			[[v animator] setFrame:NSInsetRect([v frame],-30,-30)];
			
			[NSAnimationContext endGrouping];
			
			CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
			anim.toValue = [NSNumber numberWithFloat:0.0];
			anim.duration = 0.5;
			anim.removedOnCompletion = NO;
			anim.fillMode = kCAFillModeForwards;
			
			[[v layer] addAnimation:anim forKey:@"animateOpacity"];
			
			block->y = -2;
		}
	}
}

- (void)completelyRemoveBlock:(NSTimer*)t
{
	for(TetrisBlockView * v in [t userInfo])
	{
		[v removeFromSuperview];
		
		//if([v block])
		//	libtetris_delete_block([v block]);
		
		[v setBlock:NULL];
		[v release];
	}
}

- (void)updateLocations:(NSNumber *)speed
{	
	NSMutableArray * removeList = [[NSMutableArray alloc] init];
	
	for (TetrisBlockView * v in [self subviews])
	{
		libtetris_block_t * block = [v block];
		
		if(block->y == -2)
		{
			[removeList addObject:v];
			continue;
		}

		NSRect blockRect = NSMakeRect(([self frame].size.width / TILE_WIDTH) * block->x, ([self frame].size.height / TILE_HEIGHT) * block->y, ([self frame].size.width / TILE_WIDTH), ([self frame].size.height / TILE_HEIGHT));
		
		if(!NSEqualRects([v frame], blockRect))
		{
			[NSAnimationContext beginGrouping];
			[[NSAnimationContext currentContext] setDuration:[speed floatValue]];
			
			[[v animator] setFrame:blockRect];
			
			[NSAnimationContext endGrouping];
		}
	}
	
	if([removeList count] > 0)
		[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(completelyRemoveBlock:) userInfo:removeList repeats:NO];
	else
		[removeList release];
}

- (void)setTheme:(TetrisTheme *)inTheme
{
	theme = inTheme;
	[theme setTetrisView:self];
	
	for (TetrisBlockView * v in [self subviews])
		[v setTheme:theme];
}

- (TetrisTheme *)theme
{
	return theme;
}

@end
