//
//  TetrisWindow.m
//  TetrisTests
//
//  Created by Timothy Horton on 2007.11.21.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TetrisWindow.h"

@implementation TetrisWindow

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithContentRect:frame styleMask:NSTitledWindowMask backing:NSBackingStoreRetained defer:YES];
    return self;
}

-(void)keyDown:(NSEvent *)theEvent
{
	[[self delegate] keyDown:theEvent];
}

@end
