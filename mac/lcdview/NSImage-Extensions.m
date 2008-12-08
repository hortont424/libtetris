#import "NSImage-Extensions.h"

@implementation NSImage (Extensions)

- (NSImageRep*) representationOfClass: (Class) repClass
{
	NSArray* reps = [self representations];
	unsigned i, c = [reps count];
	
	for ( i=0; i<c; i++ ) {
		NSImageRep* rep = [reps objectAtIndex:i];
		if ( [rep isKindOfClass:repClass] ) return rep;
	}
	
	return nil;
}

@end















