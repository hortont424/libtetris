#import "LCDCell.h"
#import "ATAnimation.h"
#import "ATAnimationGroup.h"
#import "ImageUtilities.h" // CreateCGImageMaskFromNSImage()
#import <stdlib.h>

@interface LCDCell (Private)
+ (NSSize) cellSizeForNumberOfDigits: (unsigned) digits groupLength: (unsigned) groupLength digitStyleDescriptor: (struct LCDStyleDescr*) styleDescr;
+ (struct LCDStyleDescr*) descriptorForLCDStyle: (LCDStyle) style;
- (void) drawDigitElements: (unsigned) elmMask opacity: (float) elmOpacity context: (CGContextRef) context;
- (int) stringOffsetForString: (NSString*) string;
+ (unsigned) elementMaskForCharacter: (unichar) c;
@end

NSString* LCDCellDidEndAnimationNotification = @"LCDCellDidEndAnimation";

#define DIGIT_ELEMENTS 7
#define LETTER_ELEMENTS 15

enum {
	LCDElm_Top = 0,
	LCDElm_Middle = 1, // corresponds to LCDElm_MiddleLeft and LCDElm_MiddleRight (for letters)
	LCDElm_Bottom = 2,
	LCDElm_LeftTop = 3,
	LCDElm_LeftBottom = 4,
	LCDElm_RightTop = 5,
	LCDElm_RightBottom = 6,
	
		/* letters */
	LCDElm_MiddleLeft = 7,
	LCDElm_MiddleRight = 8,
	LCDElm_MiddleTop = 9,
	LCDElm_MiddleBottom = 10,
	LCDElm_DiagLeftTop = 11,
	LCDElm_DiagLeftBottom = 12,
	LCDElm_DiagRightTop = 13,
	LCDElm_DiagRightBottom = 14
} LCDDigitElement;

enum {
	LCDElmMask_Top = 1 << LCDElm_Top,
	LCDElmMask_Middle = 1 << LCDElm_Middle,
	LCDElmMask_Bottom = 1 << LCDElm_Bottom,
	LCDElmMask_LeftTop = 1 << LCDElm_LeftTop,
	LCDElmMask_LeftBottom = 1 << LCDElm_LeftBottom,
	LCDElmMask_RightTop = 1 << LCDElm_RightTop,
	LCDElmMask_RightBottom = 1 << LCDElm_RightBottom,
	
		/* letters */
	LCDElmMask_MiddleLeft = 1 << LCDElm_MiddleLeft,
	LCDElmMask_MiddleRight = 1 << LCDElm_MiddleRight,
	LCDElmMask_MiddleTop = 1 << LCDElm_MiddleTop,
	LCDElmMask_MiddleBottom = 1 << LCDElm_MiddleBottom,
	LCDElmMask_DiagLeftTop = 1 << LCDElm_DiagLeftTop,
	LCDElmMask_DiagLeftBottom = 1 << LCDElm_DiagLeftBottom,
	LCDElmMask_DiagRightTop = 1 << LCDElm_DiagRightTop,
	LCDElmMask_DiagRightBottom = 1 << LCDElm_DiagRightBottom
} LCDDigitElementMask;

struct LCDStyleDescr {
	NSString*	imageName;
	CGImageRef	elementsImage;
	BOOL		canDisplayLetters;
	
	NSSize		digitSize;
	float		digitSpacing;	// horizontal spacing between adjacent digits
	float		groupSpacing;	// horizontal spacing between groups of three digits
	const CGRect* elementRects;
};

static const CGRect elmRectsDigit25[DIGIT_ELEMENTS] = {
	{ 2, 22, 10, 3 },
	{ 2, 11, 10, 3 },
	{ 2, 0, 10, 3 },
	{ 0, 13, 3, 10 },
	{ 0, 2, 3, 10 },
	{ 11, 13, 3, 10 },
	{ 11, 2, 3, 10 }
};

static struct LCDStyleDescr LCDDigit25Descr = {
	@"Digit25",
	NULL,
	NO,
	{ 14.0, 25.0 },
	3.0,
	7.0,
	elmRectsDigit25
};

static const CGRect elmRectsDigit18[DIGIT_ELEMENTS] = {
	{ 1, 16, 8, 2 },
	{ 1, 8, 8, 2 },
	{ 1, 0, 8, 2 },
	{ 0, 9, 2, 8 },
	{ 0, 1, 2, 8 },
	{ 8, 9, 2, 8 },
	{ 8, 1, 2, 8 }
};

static struct LCDStyleDescr LCDDigit18Descr = {
	@"Digit18",
	NULL,
	NO,
	{ 10.0, 18.0 },
	3.0,
	3.0,
	elmRectsDigit18
};

static const CGRect elmRectsDigit12[DIGIT_ELEMENTS] = {
	{ 1, 10, 5, 2 },
	{ 1, 5, 5, 2 },
	{ 1, 0, 5, 2 },
	{ 0, 6, 2, 5 },
	{ 0, 1, 2, 5 },
	{ 5, 6, 2, 5 },
	{ 5, 1, 2, 5 }
};

static struct LCDStyleDescr LCDDigit12Descr = {
	@"Digit12",
	NULL,
	NO,
	{ 7.0, 12.0 },
	2.0,
	4.0,
	elmRectsDigit12
};

static const CGRect elmRectsDigit11[DIGIT_ELEMENTS] = {
	{ 1, 10, 4, 1 },
	{ 1, 5, 4, 1 },
	{ 1, 0, 4, 1 },
	{ 0, 6, 1, 4 },
	{ 0, 1, 1, 4 },
	{ 5, 6, 1, 4 },
	{ 5, 1, 1, 4 }
};

static struct LCDStyleDescr LCDDigit11Descr = {
	@"Digit11",
	NULL,
	NO,
	{ 6.0, 11.0 },
	2.0,
	2.0,
	elmRectsDigit11
};

static const CGRect elmRectsDigit9[DIGIT_ELEMENTS] = {
	{ 0, 8, 5, 1 },
	{ 0, 4, 5, 1 },
	{ 0, 0, 5, 1 },
	{ 0, 4, 1, 5 },
	{ 0, 0, 1, 5 },
	{ 4, 4, 1, 5 },
	{ 4, 0, 1, 5 }
};

static struct LCDStyleDescr LCDDigit9Descr = {
	@"Digit9",
	NULL,
	NO,
	{ 5.0, 9.0 },
	2.0,
	2.0,
	elmRectsDigit9
};

static const CGRect elmRectsLetter26[LETTER_ELEMENTS] = {
	{ 1, 24, 12, 2 },
	{ 2, 12, 10, 2 },
	{ 1, 0, 12, 2 },
	{ 0, 13, 2, 12 },
	{ 0, 1, 2, 12 },
	{ 12, 13, 2, 12 },
	{ 12, 1, 2, 12 },
	
	{ 2, 12, 5, 2 },
	{ 7, 12, 5, 2 },
	{ 6, 13, 2, 11 },
	{ 6, 2, 2, 11 },
	{ 2, 14, 4, 10 },
	{ 2, 2, 4, 10 },
	{ 8, 14, 4, 10 },
	{ 8, 2, 4, 10 }
};

static struct LCDStyleDescr LCDLetter26Descr = {
	@"Letter26",
	NULL,
	YES,
	{ 14.0, 26.0 },
	/*3.0*/2.0,
	7.0,
	elmRectsLetter26
};

static const CGRect elmRectsLetter11[LETTER_ELEMENTS] = {
	{ 1, 10, 5, 1 },
	{ 1, 5, 5, 1 },
	{ 1, 0, 5, 1 },
	{ 0, 6, 1, 4 },
	{ 0, 1, 1, 4 },
	{ 6, 6, 1, 4 },
	{ 6, 1, 1, 4 },
	
	{ 1, 5, 3, 1 },
	{ 3, 5, 3, 1 },
	{ 3, 6, 1, 4 },
	{ 3, 1, 1, 4 },
	{ 1, 6, 2, 4 },
	{ 1, 1, 2, 4 },
	{ 4, 6, 2, 4 },
	{ 4, 1, 2, 4 }
};

static struct LCDStyleDescr LCDLetter11Descr = {
	@"Letter11",
	NULL,
	YES,
	{ 7.0, 11.0 },
	2.0,
	4.0,
	elmRectsLetter11
};

@implementation LCDCell

- (id) init
{
	if ( self = [super initTextCell:@""] ) {
		[self setDigitStyle:LCDStyle_Digit25];
		[self setNumberOfDigits:8];
		[self setGroupLength:0];
		[self setDrawsBackground:YES];
		[self setOpacity:1.0];
		
		[self setDigitsOnColor:[NSColor redColor]];
		[self setDigitsOffColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.1]];
		[self setBackgroundColor:[NSColor blackColor]];
		
		[self setAllowsMixedState:YES];
		[self setState:NSOnState];
		[self setStringValue:@""];
	}
	return self;
}

- (void) dealloc
{
	[myDigitsOnColor release];
	[myDigitsOffColor release];
	[myBgColor release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors/Modifiers

- (LCDStyle) digitStyle;
{
	return myDigitStyle;
}

- (void) setDigitStyle: (LCDStyle) style
{
	myDigitStyle = style;
	myStyleDescr = [[self class] descriptorForLCDStyle:style];
}

- (unsigned) numberOfDigits
{
	return myNumberOfDigits;
}

- (void) setNumberOfDigits: (unsigned) count
{
	myNumberOfDigits = count;
}

- (unsigned) groupLength
{
	return myGroupLength;
}

- (void) setGroupLength: (unsigned) length
// Pass 0 to turn grouping off.
{
	myGroupLength = length;
}

- (BOOL) drawsBackground
{
	return myFlags.drawBackground;
}

- (void) setDrawsBackground: (BOOL) flag
{
	myFlags.drawBackground = flag ? YES : NO;
}

- (float) opacity
{
	return myOpacity;
}

- (void) setOpacity: (float) opacity
{
	myOpacity = opacity;
}

#pragma mark -
#pragma mark Colors

- (NSColor*) digitsOnColor
{
	return myDigitsOnColor;
}

- (void) setDigitsOnColor: (NSColor*) color
{
	[myDigitsOnColor release];
	myDigitsOnColor = [color retain];
}

- (NSColor*) digitsOffColor
{
	return myDigitsOffColor;
}

- (void) setDigitsOffColor: (NSColor*) color
{
	[myDigitsOffColor release];
	myDigitsOffColor = [color retain];
}

- (NSColor*) backgroundColor
{
	return myBgColor;
}

- (void) setBackgroundColor: (NSColor*) color
{
	[myBgColor release];
	myBgColor = [color retain];
}

#pragma mark -
#pragma mark Geometry

+ (NSSize) cellSizeForNumberOfDigits: (unsigned) digits groupLength: (unsigned) groupLength digitStyle: (LCDStyle) style
// Returns the minimum size required to display the specified number of digits and group length with
// the specified control size.
{
	struct LCDStyleDescr* styleDescr = [self descriptorForLCDStyle:style];
	return [self cellSizeForNumberOfDigits:digits groupLength:groupLength digitStyleDescriptor:styleDescr];
}

+ (NSSize) cellSizeForNumberOfDigits: (unsigned) digits groupLength: (unsigned) groupLength digitStyleDescriptor: (struct LCDStyleDescr*) styleDescr
{
	int groupSpaces = ( groupLength > 0 ) ? (digits - 1) / groupLength : 0;
	
	NSSize viewSize;
	viewSize.width = styleDescr->digitSize.width * digits + styleDescr->digitSpacing * (digits-1) +
		styleDescr->groupSpacing * groupSpaces;
	viewSize.height = styleDescr->digitSize.height;
	
	return viewSize;
}

- (NSSize) cellSize
{
	return [[self class] cellSizeForNumberOfDigits:myNumberOfDigits groupLength:myGroupLength
		digitStyleDescriptor:myStyleDescr];
}

+ (struct LCDStyleDescr*) descriptorForLCDStyle: (LCDStyle) style
{
	switch ( style ) {
		case LCDStyle_Digit25:	return &LCDDigit25Descr;
		case LCDStyle_Digit18:	return &LCDDigit18Descr;
		case LCDStyle_Digit12:	return &LCDDigit12Descr;
		case LCDStyle_Digit11:	return &LCDDigit11Descr;
		case LCDStyle_Digit9:	return &LCDDigit9Descr;
		case LCDStyle_Letter26:	return &LCDLetter26Descr;
		case LCDStyle_Letter11:	return &LCDLetter11Descr;
	}
	return NULL;
}

#pragma mark -
#pragma mark Drawing

- (void) drawWithFrame: (NSRect) cellFrame inView: (NSView*) controlView
{
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState( context );
	CGContextSetAlpha( context, myOpacity );
	
		// draw black background
	if ( myFlags.drawBackground ) {
		CGRect r = *(CGRect*)&cellFrame;
		[myBgColor set];
		CGContextFillRect( context, r );
	}
	
	NSSize cellSize = [self cellSize];
	NSString* stringValue = [self stringToDisplay];
	int stringOffset = [self stringOffsetForString:stringValue];
	NSTextAlignment alignment = [self alignment];
	NSCellStateValue state = [self state];
	unsigned i;
	
		// center digits horizontally and vertically in cell frame
	NSPoint origin;
	origin.x = round( NSMinX(cellFrame) + (NSWidth(cellFrame) - cellSize.width) / 2 );
	origin.y = round( NSMinY(cellFrame) + (NSHeight(cellFrame) - cellSize.height) / 2 );
	CGContextTranslateCTM( context, origin.x, origin.y );
	
		// draw digits from left to right
	for ( i=0; i<myNumberOfDigits; i++ ) {
		unsigned mask = [self elementMaskForDigit:i string:stringValue stringOffset:stringOffset];
		float opacity = [self opacityForDigit:i state:state];
		
		[self drawDigitElements:mask opacity:opacity context:context];
		
		CGContextTranslateCTM( context, myStyleDescr->digitSize.width + myStyleDescr->digitSpacing, 0 );
		if ( myGroupLength > 0 ) {
			if ( (alignment == NSRightTextAlignment && (myNumberOfDigits-i-1) % 3 == 0) ||
			(alignment != NSRightTextAlignment && (i+1) % 3 == 0) ) {
				CGContextTranslateCTM( context, myStyleDescr->groupSpacing, 0 );
			}
		}
	}
	
	CGContextRestoreGState( context );
}

- (void) drawDigitElements: (unsigned) elmMask opacity: (float) elmOpacity context: (CGContextRef) context
// Draws a digit with the specified element mask at the location (0.0, 0.0) in the specified graphics
// context.
{
	CGImageRef elementsImage = myStyleDescr->elementsImage;
	const CGRect* elementRects = myStyleDescr->elementRects;
	
	if ( !elementsImage ) {
		NSString* fileName = [NSString stringWithFormat:@"LCDElements%@", myStyleDescr->imageName];
		
		NSImage* image = [NSImage imageNamed:fileName];
		NSAssert1( image, @"LCDCell: Image not found: %@!", fileName );
		
			// using a CG image mask has turned out to be more efficient than a normal CG image
		myStyleDescr->elementsImage = CreateCGImageMaskFromNSImage( image );
		NSAssert1( myStyleDescr->elementsImage, @"LCDCell: Could not create image mask for digit style %@!",
			myStyleDescr->imageName );
		
		elementsImage = myStyleDescr->elementsImage;
	}
	
		// count the LCD elements which are 'on'
	unsigned numElements = myStyleDescr->canDisplayLetters ? LETTER_ELEMENTS : DIGIT_ELEMENTS;
	unsigned i, elCountOn = 0, elCountOff = 0;
	for ( i=0; i<numElements; i++ ) {
		( elmMask & (1 << i) ) ? elCountOn++ : elCountOff++;
	}
	
	CGRect dstRect = CGRectMake( 0.0, 0.0, myStyleDescr->digitSize.width, myStyleDescr->digitSize.height );
	
	if ( elCountOn == 0 || elmOpacity == 0.0 ) { // shortcut for 'empty' digits
		CGContextSaveGState( context );
		
		CGContextClipToMask( context, dstRect, elementsImage );
		[myDigitsOffColor set];
		CGContextFillRect( context, dstRect );
		
		CGContextRestoreGState( context );
	
	} else {
	
			// collect the clip rects for the elements which are on and those which are off
		CGRect* clipRectsOn = malloc( sizeof(CGRect) * elCountOn );
		CGRect* clipRectsOff = malloc( sizeof(CGRect) * elCountOff );
		CGRect* clipRectOn = clipRectsOn, *clipRectOff = clipRectsOff;
		for ( i=0; i<numElements; i++ ) {
			if ( elmMask & (1 << i) ) *clipRectOn++ = elementRects[i];
			else *clipRectOff++ = elementRects[i];
		}
		
			// set the clip region for the LCD elements which are 'on'
		CGContextSaveGState( context );
		CGContextClipToRects( context, clipRectsOn, elCountOn );
		
			// draw the LCD elements which are 'on'
		CGContextClipToMask( context, dstRect, elementsImage );
		if ( elmOpacity == 1.0 ) [myDigitsOnColor set];
		[[myDigitsOnColor colorWithAlphaComponent:elmOpacity] set];
		CGContextFillRect( context, dstRect );
		
		CGContextRestoreGState( context );
		
			// set the clip region for the LCD elements which are 'off'
		CGContextSaveGState( context );
		CGContextClipToRects( context, clipRectsOff, numElements - elCountOn );
		
			// draw the LCD elements which are 'off'
		CGContextClipToMask( context, dstRect, elementsImage );
		[myDigitsOffColor set];
		CGContextFillRect( context, dstRect );
		
		CGContextRestoreGState( context );
		
		free( clipRectsOn );
		free( clipRectsOff );
	}
}

#pragma mark -

- (NSString*) stringToDisplay
{
	return [self stringValue];
}

- (int) stringOffsetForString: (NSString*) string
// Returns the offset between the leftmost visible digit and the string's first char: a positive value
// indicates that the leftmost digits are empty, a negative value indicates the leftmost characters of
// the string are cut off.
{
	if ( [self alignment] == NSRightTextAlignment ) {
		return myNumberOfDigits - [string length];
	} else return 0;
}

- (unsigned) elementMaskForDigit: (unsigned) index string: (NSString*) string stringOffset: (int) stringOffset
{
	int indexInString = index - stringOffset;
	if ( indexInString >= 0 && indexInString < [string length] ) {
		unichar chr = [string characterAtIndex:indexInString];
		return [[self class] elementMaskForCharacter:chr];
	} else return 0;
}

- (float) opacityForDigit: (unsigned) index state: (NSCellStateValue) state
{
	if ( state == NSOnState ) return 1.0;
	else if ( state == NSMixedState ) return 0.5;
	else return 0.0;
}

+ (unsigned) elementMaskForCharacter: (unichar) c
{
	switch ( c ) {
		case '-':
			return LCDElmMask_Middle;
		case '0':
			return LCDElmMask_Top | LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case '1':
			return LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case '2':
			return LCDElmMask_Top | LCDElmMask_Middle | LCDElmMask_Bottom |
				LCDElmMask_LeftBottom | LCDElmMask_RightTop;
		case '3':
			return LCDElmMask_Top | LCDElmMask_Middle | LCDElmMask_Bottom |
				LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case '4':
			return LCDElmMask_Middle |
				LCDElmMask_LeftTop | LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case '5':
			return LCDElmMask_Top | LCDElmMask_Middle | LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_RightBottom;
		case '6':
			return LCDElmMask_Top | LCDElmMask_Middle | LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightBottom;
		case '7':
			return LCDElmMask_Top |
				LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case '8':
			return LCDElmMask_Top | LCDElmMask_Middle | LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case '9':
			return LCDElmMask_Top | LCDElmMask_Middle | LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_RightTop | LCDElmMask_RightBottom;
		
			/* letters */
		case 'A':
			return LCDElmMask_Top | LCDElmMask_MiddleLeft | LCDElmMask_MiddleRight |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case 'B':
			return LCDElmMask_Top | LCDElmMask_Bottom | LCDElmMask_MiddleRight |
				LCDElmMask_RightTop | LCDElmMask_RightBottom |
				LCDElmMask_MiddleTop | LCDElmMask_MiddleBottom;
		case 'C':
			return LCDElmMask_Top | LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom;
		case 'D':
			return LCDElmMask_Top | LCDElmMask_Bottom |
				LCDElmMask_RightTop | LCDElmMask_RightBottom |
				LCDElmMask_MiddleTop | LCDElmMask_MiddleBottom;
		case 'E':
			return LCDElmMask_Top | LCDElmMask_Bottom | LCDElmMask_MiddleLeft | LCDElmMask_MiddleRight |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom;
		case 'F':
			return LCDElmMask_Top | LCDElmMask_MiddleLeft | LCDElmMask_MiddleRight |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom;
		case 'G':
			return LCDElmMask_Top | LCDElmMask_Bottom | LCDElmMask_MiddleRight |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightBottom;
		case 'H':
			return LCDElmMask_MiddleLeft | LCDElmMask_MiddleRight |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case 'I':
			return LCDElmMask_Top | LCDElmMask_Bottom |
				LCDElmMask_MiddleTop | LCDElmMask_MiddleBottom;
		case 'J':
			return LCDElmMask_Bottom |
				LCDElmMask_LeftBottom | LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case 'K':
			return LCDElmMask_MiddleLeft |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom |
				LCDElmMask_DiagRightTop | LCDElmMask_DiagRightBottom;
		case 'L':
			return LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom;
		case 'M':
			return LCDElmMask_Top |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop | LCDElmMask_RightBottom |
				LCDElmMask_MiddleTop;
		case 'N':
			return LCDElmMask_LeftTop | LCDElmMask_LeftBottom |
				LCDElmMask_RightTop | LCDElmMask_RightBottom |
				LCDElmMask_DiagLeftTop | LCDElmMask_DiagRightBottom;
		case 'O':
			return LCDElmMask_Top | LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case 'P':
			return LCDElmMask_Top | LCDElmMask_MiddleLeft | LCDElmMask_MiddleRight |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop;
		case 'Q':
			return LCDElmMask_Top | LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop | LCDElmMask_RightBottom |
				LCDElmMask_DiagRightBottom;
		case 'R':
			return LCDElmMask_Top | LCDElmMask_MiddleLeft | LCDElmMask_MiddleRight |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop |
				LCDElmMask_DiagRightBottom;
		case 'S':
			return LCDElmMask_Top | LCDElmMask_MiddleLeft | LCDElmMask_MiddleRight | LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_RightBottom;
		case 'T':
			return LCDElmMask_Top |
				LCDElmMask_MiddleTop | LCDElmMask_MiddleBottom;
		case 'U':
			return LCDElmMask_Bottom |
				LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop | LCDElmMask_RightBottom;
		case 'V':
			return LCDElmMask_LeftTop | LCDElmMask_LeftBottom |
				LCDElmMask_DiagLeftBottom | LCDElmMask_DiagRightTop;
		case 'W':
			return LCDElmMask_LeftTop | LCDElmMask_LeftBottom | LCDElmMask_RightTop |
				LCDElmMask_RightBottom |
				LCDElmMask_MiddleTop |
				LCDElmMask_DiagLeftBottom | LCDElmMask_DiagRightBottom;
		case 'X':
			return LCDElmMask_DiagLeftTop | LCDElmMask_DiagLeftBottom |
				LCDElmMask_DiagRightTop | LCDElmMask_DiagRightBottom;
		case 'Y':
			return LCDElmMask_MiddleBottom |
				LCDElmMask_DiagLeftTop | LCDElmMask_DiagRightTop;
		case 'Z':
			return LCDElmMask_Top | LCDElmMask_Bottom |
				LCDElmMask_DiagLeftBottom | LCDElmMask_DiagRightTop;
		case '\'':
			return LCDElmMask_MiddleTop;
		case '(':
			return LCDElmMask_DiagRightTop | LCDElmMask_DiagRightBottom;
		case ')':
			return LCDElmMask_DiagLeftTop | LCDElmMask_DiagLeftBottom;
		case '*':
			return LCDElmMask_MiddleLeft | LCDElmMask_MiddleRight |
				LCDElmMask_MiddleTop | LCDElmMask_MiddleBottom |
				LCDElmMask_DiagLeftTop | LCDElmMask_DiagLeftBottom |
				LCDElmMask_DiagRightTop | LCDElmMask_DiagRightBottom;
		case '+':
			return LCDElmMask_MiddleLeft | LCDElmMask_MiddleRight |
				LCDElmMask_MiddleTop | LCDElmMask_MiddleBottom;
		case '/':
			return LCDElmMask_DiagLeftBottom | LCDElmMask_DiagRightTop;
		case '_':
			return LCDElmMask_Bottom;
		case '<':
			return LCDElmMask_DiagRightTop | LCDElmMask_DiagRightBottom;
		case '>':
			return LCDElmMask_DiagLeftTop | LCDElmMask_DiagLeftBottom;
		case '\\':
			return LCDElmMask_DiagLeftTop | LCDElmMask_DiagRightBottom;
		case '|':
			return LCDElmMask_MiddleTop | LCDElmMask_MiddleBottom;
		default:
			return 0;
	}
}

@end

#pragma mark -

@interface AnimatedLCDCell (Private)
- (void) fillCharElmMasksArray: (NSMutableArray*) charElmMasksArray progress: (float) progress;
- (void) killAllAnimations;
@end

@implementation AnimatedLCDCell

- (id) initWithControlView: (NSView*) controlView
{
	if ( self = [super init] ) {
		myCounterAnimation = [[ATViewAnimation alloc] initWithDelegate:self targetView:controlView
			duration:0.2];
		[myCounterAnimation setUserRef:@"Counter"];
		
		myRandomnessAnimation = [[ATViewAnimation alloc] initWithDelegate:self targetView:controlView
			duration:0.4];
		[myRandomnessAnimation setUserRef:@"Randomness"];
		
		myScrollTextAnimation = [[ATViewAnimation alloc] initWithDelegate:self targetView:controlView
			duration:FLT_MAX]; /* duration not used (animation stops itself) */
		[myScrollTextAnimation setRefreshInterval:0.1];
		[myScrollTextAnimation setUserRef:@"ScrollText"];
		
		myFadeDigitsAnimation = [[ATViewAnimation alloc] initWithDelegate:self targetView:controlView
			duration:0.2];
		[myFadeDigitsAnimation setUserRef:@"FadeDigits"];
	}
	return self;
}

- (void) dealloc
{
	[myCounterAnimation release];
	[myRandomnessAnimation release];
	[myScrollTextAnimation release];
	[myFadeDigitsAnimation release];
	[super dealloc];
}

#pragma mark -
#pragma mark Animation Optimization

- (void) setAnimationRect: (NSRect) rect
{
	[myCounterAnimation setDrawingRect:rect];
	[myRandomnessAnimation setDrawingRect:rect];
	[myScrollTextAnimation setDrawingRect:rect];
	[myFadeDigitsAnimation setDrawingRect:rect];
}

- (void) addAnimationsToGroup: (ATAnimationGroup*) animGroup
{
	[animGroup addAnimations:
		myCounterAnimation,
		myRandomnessAnimation,
		myFadeDigitsAnimation,
		nil];
	
	// Don't add myScrollTextAnimation; it has a different refresh interval.
}

#pragma mark -
#pragma mark State

- (void) setState: (int) newState
{
	if ( newState > 0 ) newState = NSOnState;
	else if ( newState < 0 ) newState = NSMixedState;
	
	if ( newState != [self state] ) {
		[self killAllAnimations];
		[super setState:newState];
	}
}

- (void) setState: (int) newState animationType: (LCDCellAnimation) animType
// Allowed states are NSOnState (digits visible), NSOffState (no digits visible), and NSMixedState
// (digits dimmed). Possible animation types are LCDCellRandomnessAnimation and LCDCellFadeDigitsAnimation.
// LCDCellRandomnessAnimation only looks good if either the old or new state is NSOffState.
{
	int oldState = [self state];
	if ( newState > 0 ) newState = NSOnState;
	else if ( newState < 0 ) newState = NSMixedState;
	
	if ( newState != oldState ) {
		[self setState:newState];
		
		if ( animType == LCDCellRandomnessAnimation ) {
			NSMutableDictionary* dict = [NSMutableDictionary dictionary];
			if ( newState != 0 ) { // turn on
				[dict setObject:@"" forKey:@"OldString"];
				[dict setObject:[self stringValue] forKey:@"NewString"];
				[dict setObject:[NSNumber numberWithFloat:[self opacityForDigit:0 state:newState]]
					forKey:@"DigitOpacity"];
			} else { // turn off
				[dict setObject:[self stringValue] forKey:@"OldString"];
				[dict setObject:@"" forKey:@"NewString"];
				[dict setObject:[NSNumber numberWithFloat:[self opacityForDigit:0 state:oldState]]
					forKey:@"DigitOpacity"];
			}
			
			[myRandomnessAnimation setUserRef:dict];
			[myRandomnessAnimation run];
			
		} else if ( animType == LCDCellFadeDigitsAnimation ) {
			float oldOpacity = [self opacityForDigit:0 state:oldState];
			float newOpacity = [self opacityForDigit:0 state:newState];
			
			[myFadeDigitsAnimation runFrom:oldOpacity to:newOpacity];
		}
	}
}

#pragma mark -
#pragma mark Value

- (void) setStringValue: (NSString*) newString
{
	if ( ![newString isEqualToString:[self stringValue]] ) {
		[self killAllAnimations];
		[super setStringValue:newString];
	}
}

- (void) setStringValue: (NSString*) newString animationType: (LCDCellAnimation) animType
// Possible animation types are LCDCellCounterAnimation, LCDCellRandomnessAnimation, and 
// LCDCellScrollTextAnimation.
{
	NSParameterAssert( newString != nil );
	NSString* oldString = [[self stringValue] retain];
	
	if ( ![newString isEqualToString:oldString] ) {
		[self setStringValue:newString];
		
		if ( animType == LCDCellCounterAnimation ) { // assumes the old and new value are integers
			NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				oldString, @"OldString", newString, @"NewString", nil];
			
			[myCounterAnimation setUserRef:dict];
			[myCounterAnimation run];
			
		} else if ( animType == LCDCellRandomnessAnimation ) {
			NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				oldString, @"OldString", newString, @"NewString", nil];
				[dict setObject:[NSNumber numberWithFloat:[self opacityForDigit:0 state:[self state]]]
					forKey:@"DigitOpacity"];
			
			[myRandomnessAnimation setUserRef:dict];
			[myRandomnessAnimation run];
			
		} else if ( animType == LCDCellScrollTextAnimation ) {
			[myScrollTextAnimation run];
		}
	}
	
	[oldString release];
}

- (void) setIntValue: (int) newValue
{
	[self setStringValue:[NSString stringWithFormat:@"%d", newValue]];
}

- (void) setIntValue: (int) newValue animationType: (LCDCellAnimation) animType
{
	[self setStringValue:[NSString stringWithFormat:@"%d", newValue] animationType:animType];
}

#pragma mark -

- (void) animationWillStart: (ATAnimation*) animation
{
	if ( animation == myRandomnessAnimation ) {
		
			// initialize character elements
		NSMutableArray* charElmMasksArray = [NSMutableArray arrayWithCapacity:[self numberOfDigits]];
		[self fillCharElmMasksArray:charElmMasksArray progress:0.0];
		
		NSMutableDictionary* dict = [animation userRef];
		[dict setObject:charElmMasksArray forKey:@"CharElmMasksArray"];
		
	} else if ( animation == myScrollTextAnimation ) {
		int curScrollOffset = [self numberOfDigits];
		NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:curScrollOffset], @"ScrollOffset", nil];
		[animation setUserRef:dict];
	}
}

- (void) refreshAnimation: (ATAnimation*) animation
{
	if ( animation == myRandomnessAnimation ) {
		NSMutableDictionary* dict = [animation userRef];
		
			// change character elements according to current progress
		NSMutableArray* charElmMasksArray = [dict objectForKey:@"CharElmMasksArray"];
		[self fillCharElmMasksArray:charElmMasksArray progress:[animation progress]];
		
	} else if ( animation == myScrollTextAnimation ) {
		NSMutableDictionary* dict = [animation userRef];
		int curScrollOffset = [[dict objectForKey:@"ScrollOffset"] intValue];
		
		if ( curScrollOffset == -[[self stringValue] length] ) {
			[animation stop];
			return;
		}
		
		[dict setObject:[NSNumber numberWithInt:curScrollOffset - 1] forKey:@"ScrollOffset"];
	}
}

- (void) animationDidEnd: (ATAnimation*) animation
{
	[self animationDidStop:animation];
}

- (void) animationDidStop: (ATAnimation*) animation
{
	int animType;
	if ( animation == myCounterAnimation ) animType = LCDCellCounterAnimation;
	else if ( animation == myRandomnessAnimation ) animType = LCDCellRandomnessAnimation;
	else if ( animation == myScrollTextAnimation ) animType = LCDCellScrollTextAnimation;
	else if ( animation == myFadeDigitsAnimation ) animType = LCDCellFadeDigitsAnimation;
	else animType = 0;
	
	NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:animType]
		forKey:@"AnimationType"];
	[[NSNotificationCenter defaultCenter] postNotificationName:LCDCellDidEndAnimationNotification
		object:self userInfo:dict];
}

#pragma mark -

- (void) fillCharElmMasksArray: (NSMutableArray*) charElmMasksArray progress: (float) progress
{
	static BOOL didSeedRandomNumberGenerator = NO;
	if ( !didSeedRandomNumberGenerator ) {
		struct timeval systime;
		gettimeofday( &systime, NULL );
		srand48( systime.tv_usec );
		didSeedRandomNumberGenerator = YES;
	}
	
	unsigned numChars = [self numberOfDigits];
	NSDictionary* dict = [myRandomnessAnimation userRef];
	NSString* oldString = [dict objectForKey:@"OldString"];
	NSString* newString = [dict objectForKey:@"NewString"];
	int stringOffsetOld = [self stringOffsetForString:oldString];
	int stringOffsetNew = [self stringOffsetForString:newString];
	
	unsigned numElements = myStyleDescr->canDisplayLetters ? LETTER_ELEMENTS : DIGIT_ELEMENTS;
	unsigned i, j;
	
	for ( i=0; i<numChars; i++ ) {
		unsigned maskOld = [super elementMaskForDigit:i string:oldString stringOffset:stringOffsetOld];
		unsigned maskNew = [super elementMaskForDigit:i string:newString stringOffset:stringOffsetNew];
		
		unsigned mask = 0;
		if ( maskOld || maskNew ) {
			unsigned elmMask = 1;
			for ( j=0; j<numElements; j++ ) {
				float r = drand48();
				float p1 = MAX( 0.0, 1.0 - 2.0 * progress );
				float p2 = MAX( 0.0, 2.0 * progress - 1.0 );
				
					// Display the old char's element with probability p1.
					// Display the new char's element with probability p2.
					// Display random element with probability 1.0 - p1 - p2.
				
				if ( r < p1 ) {
					if ( maskOld & elmMask ) mask |= elmMask;
				} else if ( r >= 1.0 - p2 ) {
					if ( maskNew & elmMask ) mask |= elmMask;
				} else {
					if ( drand48() < 0.5 ) mask |= elmMask;
				}
				
				elmMask = elmMask << 1;
			}
		}
		
		[charElmMasksArray insertObject:[NSNumber numberWithUnsignedInt:mask] atIndex:i];
	}
}

- (NSString*) stringToDisplay
{
	if ( [myCounterAnimation isRunning] ) {
		NSMutableDictionary* dict = [myCounterAnimation userRef];
		int oldValue = [[dict objectForKey:@"OldString"] intValue];
		int newValue = [[dict objectForKey:@"NewString"] intValue];
		int curValue = oldValue + ( newValue - oldValue ) * [myCounterAnimation progress];
		return [NSString stringWithFormat:@"%d", curValue];
		
	} else return [super stringToDisplay];
}

- (unsigned) elementMaskForDigit: (unsigned) index string: (NSString*) string stringOffset: (int) stringOffset
{
	if ( [myRandomnessAnimation isRunning] ) {
		NSMutableDictionary* dict = [myRandomnessAnimation userRef];
		NSMutableArray* charElmMasksArray = [dict objectForKey:@"CharElmMasksArray"];
		
		return [[charElmMasksArray objectAtIndex:index] unsignedIntValue];
		
	} else if ( [myScrollTextAnimation isRunning] ) {
		NSMutableDictionary* dict = [myScrollTextAnimation userRef];
		int curScrollOffset = [[dict objectForKey:@"ScrollOffset"] intValue];
		return [super elementMaskForDigit:index string:string stringOffset:curScrollOffset];
		
	} else return [super elementMaskForDigit:index string:string stringOffset:stringOffset];
}

- (float) opacityForDigit: (unsigned) index state: (NSCellStateValue) state
{
	if ( [myRandomnessAnimation isRunning] ) {
		NSMutableDictionary* dict = [myRandomnessAnimation userRef];
		return [[dict objectForKey:@"DigitOpacity"] floatValue];
		
	} else if ( [myFadeDigitsAnimation isRunning] ) {
		return [myFadeDigitsAnimation progress];
		
	} else return [super opacityForDigit:index state:state];
}

- (void) killAllAnimations
{
	if ( [myCounterAnimation isRunning] ) [myCounterAnimation stop];
	if ( [myRandomnessAnimation isRunning] ) [myRandomnessAnimation stop];
	if ( [myScrollTextAnimation isRunning] ) [myScrollTextAnimation stop];
	if ( [myFadeDigitsAnimation isRunning] ) [myFadeDigitsAnimation stop];
}

@end










