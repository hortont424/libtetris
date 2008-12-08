//
//  Controller.h
//  TetrisTests
//
//  Created by Timothy Horton on 2007.11.20.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "tetris.h"
#import <TetrisBlockView.h>
#import <TetrisTheme.h>

#define FAST_SPEED 0.1
#define NORMAL_SPEED 0.2

@class RemoteControl;
@class MultiClickRemoteBehavior;
@class WiiRemote;
@class WiiRemoteDiscovery;

@interface Controller : NSObject
{
	IBOutlet id tetrisView;
	IBOutlet id myLCDView;
	libtetris_game_t * game;
	libtetris_block_t * currentBlock;
	
	NSTimer * timer;
	TetrisTheme * theme;
	
	int deleteRow;
	
	RemoteControl* remoteControl;
	MultiClickRemoteBehavior* remoteControlBehavior;
	
	WiiRemoteDiscovery *discovery;
	WiiRemote *wiiremote;
	
	bool WII_RIGHTING, WII_LEFTING;
}

- (RemoteControl*) remoteControl;
- (void)handleKeyPress:(int)inChar;

@end
