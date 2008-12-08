//
//  TetrisView.h
//  TetrisTests
//
//  Created by Timothy Horton on 2007.11.20.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Controller.h>
#import <TetrisBlockView.h>
#import <TetrisTheme.h>

@interface TetrisView : NSView
{
	IBOutlet Controller * controller;
	TetrisTheme * theme;
}

- (void)updateLocations:(NSNumber *)speed;

- (void)setTheme:(TetrisTheme *)inTheme;
- (TetrisTheme *)theme;

@end
