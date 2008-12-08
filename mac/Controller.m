//
//  Controller.m
//  TetrisTests
//
//  Created by Timothy Horton on 2007.11.20.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "QuartzCore/CAAnimation.h"
#import "LCDView.h"
#import "LCDCell.h"
#import "AppleRemote.h"
//#import "WiiRemote/WiiRemote.h"
//#import "WiiRemote/WiiRemoteDiscovery.h"

@implementation Controller

- (void)resetTimer
{
	[timer invalidate];
	[timer release];
	timer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doStep:) userInfo:nil repeats:YES] retain];
}

- (void)addBlockView:(libtetris_block_t *)block
{
	TetrisBlockView * newBlock = [[TetrisBlockView alloc] initWithFrame:NSMakeRect(([tetrisView frame].size.width / TILE_WIDTH) * block->x, ([tetrisView frame].size.height / TILE_HEIGHT) * block->y, ([tetrisView frame].size.width / TILE_WIDTH), ([tetrisView frame].size.height / TILE_HEIGHT))];
	[newBlock setBlock:block];
	[newBlock setTheme:theme];
	[tetrisView addSubview:newBlock];
}

- (void)awakeFromNib
{
	[myLCDView setDigitStyle:LCDStyle_Letter26];
	[myLCDView setIntValue:0 animationType:LCDCellCounterAnimation];
	
	theme = [[TetrisTheme alloc] init];
	[tetrisView setTheme:theme];
	
	[[tetrisView layer] setOpacity:0.0];
	deleteRow = 0;
	
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(initialize:) userInfo:nil repeats:NO];
	
	remoteControl = [[[AppleRemote alloc] initWithDelegate: self] retain];
	[remoteControl startListening: self];
	
	//discovery = [[WiiRemoteDiscovery alloc] init];
	//[discovery setDelegate:self];
	
	//IOReturn theResult = [discovery start];
}

/*- (void)WiiRemoteDiscovered:(WiiRemote*)inwiimote
{
	NSLog(@"DISCOVERED");
	
	[discovery stop];
	
	wiiremote = [inwiimote retain];
	
	[wiiremote setDelegate:self];
	
	[wiiremote setIRSensorEnabled:NO];
	[wiiremote setForceFeedbackEnabled:NO];
	[wiiremote setMotionSensorEnabled:YES];
}*/

- (void)applicationWillTerminate:(NSNotification *)inNotification
{
	NSLog(@"QUIT");
	/*if (discovery)
	{
		[discovery stop];
		[discovery autorelease];
		discovery = NULL;
	}
	
	if (wiiremote)
	{
		[wiiremote close];
		[wiiremote autorelease];
		wiiremote = NULL;
	}*/
}

/*- (void)WiiRemoteDiscoveryError:(float)code
{
	NSLog(@"ERROR: %d", code);
	if (discovery)
	{
		[discovery stop];
		[discovery autorelease];
		discovery = NULL;
	}
	
	discovery = [[WiiRemoteDiscovery discoveryWithDelegate:self] retain];
	NSLog(@"%d", discovery);
	
	IOReturn theResult = [(WiiRemoteDiscovery *)discovery start];
	NSLog(@"%d", theResult);
}*/

/*- (void) accelerationChanged:(unsigned short)buttonData accX:(unsigned char)accX accY:(unsigned char)accY accZ:(unsigned char)accZ wiiRemote:(WiiRemote *)inwiimote
{
	//NSLog(@"buttonData: %d", buttonData);
	
	//NSLog(
	
	if(WII_RIGHTING)
	{
		if(131-accX > -50)
		{
			WII_RIGHTING = false;
			NSLog(@"Not Righting");
		}
	}
	
	if(WII_LEFTING)
	{
		if(131-accX < 50)
		{
			WII_LEFTING = false;
			NSLog(@"Not Lefting");
		}
	}
	
	if(131-accX > 100)
	{
		if(!WII_RIGHTING && !WII_LEFTING)
		{
			NSLog(@"left");
			NSLog(@"accXYZ: %d, %d, %d", 131-accX, 127-accY, 154-accZ);
			[self handleKeyPress:NSLeftArrowFunctionKey];
			WII_LEFTING = true;
		}
	}
	else if(131-accX < -100)
	{
		if(!WII_RIGHTING && !WII_LEFTING)
		{
			NSLog(@"right");
			NSLog(@"accXYZ: %d, %d, %d", 131-accX, 127-accY, 154-accZ);
			[self handleKeyPress:NSRightArrowFunctionKey];
			WII_RIGHTING = true;
		}
	}
}*/

- (void) sendRemoteButtonEvent: (RemoteControlEventIdentifier) event pressedDown: (BOOL) pressedDown remoteControl: (RemoteControl*) remoteControl
{
	if(!pressedDown)
		return;
	
	switch(event)
	{
		case kRemoteButtonLeft:		[self handleKeyPress:NSLeftArrowFunctionKey]; break;
		case kRemoteButtonRight:	[self handleKeyPress:NSRightArrowFunctionKey]; break;
		case kRemoteButtonMinus:	[self handleKeyPress:NSDownArrowFunctionKey]; break;
		case kRemoteButtonPlus:		[self handleKeyPress:NSUpArrowFunctionKey]; break;
		case kRemoteButtonPlay:		[self handleKeyPress:' ']; break;
	}
}

- (void)initialize:(NSTimer*)inTimer
{
	CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
	anim.toValue = [NSNumber numberWithFloat:1.0];
	anim.fromValue = [NSNumber numberWithFloat:0.0];
	anim.duration = 1.0;
	anim.removedOnCompletion = NO;
	anim.fillMode = kCAFillModeForwards;
	
	[[tetrisView layer] addAnimation:anim forKey:@"animateOpacity"];
	
	game = libtetris_create_game();
	
	[NSTimer scheduledTimerWithTimeInterval:1.1 target:self selector:@selector(beginPlay:) userInfo:nil repeats:NO];
}

- (void)beginPlay:(NSTimer*)inTimer
{
	currentBlock = libtetris_create_random();
	
	for(int i = 0; i < g_list_length(currentBlock->connections); i++)
	{
		libtetris_block_t * block = (libtetris_block_t *)g_list_nth_data(currentBlock->connections, i);
		
		game->blocks = g_list_prepend(game->blocks,block);
		
		[self addBlockView:block];
	}
	
	timer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doStep:) userInfo:nil repeats:YES] retain];
}

- (void)deleteNumberedRow:(NSTimer*)timer
{
	[self deleteRow:deleteRow--];
}

- (void)lostGame
{
	[timer invalidate];
	[timer release];
	currentBlock = NULL;
	
	int i;
	deleteRow = TILE_HEIGHT - 1;
	for(i = TILE_HEIGHT - 1; i >= 0; i--)
		[NSTimer scheduledTimerWithTimeInterval:(((float)i + 1)/10.0) target:self selector:@selector(deleteNumberedRow:) userInfo:nil repeats:NO];
}

- (void)doStep:(NSTimer *)timer
{
	if(!currentBlock)
	{
		currentBlock = libtetris_create_random();
		
		for(gint i = 0; i < g_list_length(currentBlock->connections); i++)
		{
			libtetris_block_t * block = (libtetris_block_t *)g_list_nth_data(currentBlock->connections, i);
			
			game->blocks = g_list_prepend(game->blocks,block);
			
			[self addBlockView:block];
		}
	}
		
	if(!libtetris_move_block(game, currentBlock, LIBTETRIS_DOWN))
	{
		for(gint i = 0; i < g_list_length(currentBlock->connections); i++)
		{
			libtetris_block_t * block = (libtetris_block_t *)g_list_nth_data(currentBlock->connections, i);
			
			if(block->y >= TILE_HEIGHT)
			{
				[self lostGame];
				return;
			}
		}
		
		[self checkAndCleanRows];
	}
	
	[tetrisView updateLocations:[NSNumber numberWithFloat:NORMAL_SPEED]];
}

- (void)deleteRow:(int)row
{
	libtetris_block_t * toDisconnect[g_list_length(game->blocks)];
	
	for(gint j = 0; j < g_list_length(game->blocks); j++)
	{
		libtetris_block_t * block = ((libtetris_block_t *)g_list_nth_data(game->blocks, j));
		
		if(block->y == row)
			toDisconnect[j] = block;
		else
			toDisconnect[j] = NULL;
	}
	
	int origlen = g_list_length(game->blocks);
	
	for(gint j = 0; j < origlen; j++)
		if(toDisconnect[j])
			libtetris_disconnect_block(game, toDisconnect[j]);
	
	[tetrisView explodeRow:row];
}

- (void)checkAndCleanRows
{
	[self resetTimer];
	
	int i;
	
	int rows[TILE_HEIGHT];
	
	for(i = 0; i < TILE_HEIGHT; i++) rows[i] = 0;
	
	for(i = 0; i < g_list_length(game->blocks); i++)
	{
		libtetris_block_t * block = ((libtetris_block_t *)g_list_nth_data(game->blocks, i));
		rows[block->y]++;
	}
	
	NSMutableArray * toBeRemoved = [[NSMutableArray alloc] init];
	
	for(i = TILE_HEIGHT - 1; i >= 0; i--)
		if(rows[i] == TILE_WIDTH)
			[toBeRemoved addObject:[NSNumber numberWithUnsignedInt:i]];
	
	for (id v in toBeRemoved)
	{
		[self deleteRow:[v unsignedIntValue]];
		libtetris_drop_all_above(game, [v unsignedIntValue]);
	}
	
	if(libtetris_update_score(game, [toBeRemoved count]))
		[myLCDView setIntValue:game->score animationType:LCDCellCounterAnimation];
	
	currentBlock = 0;
	[timer fire];
	
	[toBeRemoved release];
}

- (void)handleKeyPress:(int)inChar
{
	if(!currentBlock) // this only works until we want keys for something else. then, put them above.
		return;
	
	libtetris_block_t * copy = libtetris_copy_block(currentBlock);
	bool canMoveDown = false; //libtetris_move_block(game, copy, LIBTETRIS_DOWN);
	
	if(inChar == NSLeftArrowFunctionKey)
	{
		if(libtetris_move_block(game, currentBlock, LIBTETRIS_LEFT) && canMoveDown)
			[self resetTimer];
	}
	else if(inChar == NSRightArrowFunctionKey)
	{
		if(libtetris_move_block(game, currentBlock, LIBTETRIS_RIGHT) && canMoveDown)
			[self resetTimer];
	}
	else if(inChar == NSDownArrowFunctionKey)
	{
		if(libtetris_move_block(game, currentBlock, LIBTETRIS_DOWN))
			[self resetTimer];
	}
	else if(inChar == NSUpArrowFunctionKey)
	{
		if(libtetris_rotate_block(game, currentBlock) && canMoveDown)
			[self resetTimer];
	}
	else if(inChar == ' ')
	{
		if(libtetris_move_block(game, currentBlock, LIBTETRIS_DOWN))
		{
			while(libtetris_move_block(game, currentBlock, LIBTETRIS_DOWN));
			[self resetTimer];
		}
	}
	
	[tetrisView updateLocations:[NSNumber numberWithFloat:FAST_SPEED]];
}

- (void)keyDown:(NSEvent *)theEvent
{
	[self handleKeyPress:[[theEvent characters] characterAtIndex:0]];
}

- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize
{
	NSSize newSize;
	newSize.width = proposedFrameSize.width;
	newSize.height = (2*([tetrisView frame].size.width/[window frame].size.width)*proposedFrameSize.width)*([window frame].size.height/[tetrisView frame].size.height);
	
	return newSize;
}

- (void)windowDidResize:(NSNotification *)notification
{
	[self resetTimer];
	[tetrisView updateLocations:[NSNumber numberWithFloat:0.0]];
}

@end
