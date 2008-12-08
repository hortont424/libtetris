#import <Cocoa/Cocoa.h>

// This class only serves as a demonstration for the LCDCell class.

@class AnimatedLCDCell;

@interface LCDView : NSView
{
	AnimatedLCDCell* myCell;
	
	struct {
		unsigned isSetUp:1;
	} myFlags;
}

@end
