#import "LCDView.h"
#import "LCDCell.h"

@interface LCDView (Private)
- (void) setUp;
@end

@implementation LCDView

- (id) initWithFrame: (NSRect) frame
{
	if ( self = [super initWithFrame:frame] ) {
		[self setUp];
	}
	return self;
}

- (void) awakeFromNib
{
	[self setUp];
}

- (void) setUp
{
	if ( myFlags.isSetUp ) return;
	myFlags.isSetUp = YES;
	
	myCell = [[AnimatedLCDCell alloc] initWithControlView:self];
	[myCell setDigitStyle:LCDStyle_Letter26];
	[myCell setGroupLength:0];
}

- (void) dealloc
{
	[myCell release];
	[super dealloc];
}

#pragma mark -

- (void) forwardInvocation: (NSInvocation*) invocation
{
	if ( [myCell respondsToSelector:[invocation selector]] ) {
		[invocation invokeWithTarget:myCell];
	} else [super forwardInvocation:invocation];
}

- (NSMethodSignature*) methodSignatureForSelector: (SEL) selector
{
	NSMethodSignature* signature = [myCell methodSignatureForSelector:selector];
	if ( signature ) return signature;
	
	return [super methodSignatureForSelector:selector];
}

#pragma mark -

- (void) drawRect: (NSRect) rect
{
	[myCell drawWithFrame:[self bounds] inView:self];
}

@end
