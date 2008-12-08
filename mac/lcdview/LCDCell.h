// =================================================================================================
//  LCDCell                                                                  version 1.1 [July 2006]
//
//      by Simon Haertel
//      e-mail: simonhaertel@web.de
//      web:    www.simonhaertel.de.vu
//
//      See the Read Me file for more information.

#import <Cocoa/Cocoa.h>

	// LCD styles -- These define the appearance and size of the digits. Some styles can only display
	// digits (0..9), others can also display uppercase letters and a few other characters. There's an
	// image file for each of them. The number corresponds to the height of one digit, in pixels.
typedef enum {
	LCDStyle_Digit25,
	LCDStyle_Digit18,
	LCDStyle_Digit12,
	LCDStyle_Digit11,
	LCDStyle_Digit9,
	LCDStyle_Letter26,
	LCDStyle_Letter11
} LCDStyle;

struct LCDStyleDescr;

@interface LCDCell : NSCell
{
	LCDStyle		myDigitStyle;
	unsigned		myNumberOfDigits;
	unsigned		myGroupLength; // 0 means no groups
	float			myOpacity;
	struct LCDStyleDescr* myStyleDescr;
	
	NSColor*		myDigitsOnColor;
	NSColor*		myDigitsOffColor;
	NSColor*		myBgColor;
	
	struct {
		unsigned drawBackground:1;
	} myFlags;
}

	// Accessors/Modifiers
- (LCDStyle) digitStyle;
- (void) setDigitStyle: (LCDStyle) style;
- (unsigned) numberOfDigits;
- (void) setNumberOfDigits: (unsigned) count;
- (unsigned) groupLength;
- (void) setGroupLength: (unsigned) length;
- (BOOL) drawsBackground;
- (void) setDrawsBackground: (BOOL) flag;
- (float) opacity;
- (void) setOpacity: (float) opacity;

	// Colors
- (NSColor*) digitsOnColor;
- (void) setDigitsOnColor: (NSColor*) color;
- (NSColor*) digitsOffColor;
- (void) setDigitsOffColor: (NSColor*) color;
- (NSColor*) backgroundColor;
- (void) setBackgroundColor: (NSColor*) color;

	// Geometry
+ (NSSize) cellSizeForNumberOfDigits: (unsigned) digits groupLength: (unsigned) groupLength digitStyle: (LCDStyle) digitStyle;
- (NSSize) cellSize;

	// For Subclassers
- (NSString*) stringToDisplay;
- (unsigned) elementMaskForDigit: (unsigned) index string: (NSString*) string stringOffset: (int) stringOffset;
- (float) opacityForDigit: (unsigned) index state: (NSCellStateValue) state;
@end

typedef enum {
	LCDCellCounterAnimation = 200,	// only for value changes
	LCDCellRandomnessAnimation,		// for state and value changes
	LCDCellScrollTextAnimation,		// only for value changes
	LCDCellFadeDigitsAnimation		// only for state changes
} LCDCellAnimation;

extern NSString* LCDCellDidEndAnimationNotification;

@class ATViewAnimation;
@class ATAnimationGroup;

@interface AnimatedLCDCell : LCDCell
{
	ATViewAnimation*	myCounterAnimation;
	ATViewAnimation*	myRandomnessAnimation;
	ATViewAnimation*	myScrollTextAnimation;
	ATViewAnimation*	myFadeDigitsAnimation;
}

- (id) initWithControlView: (NSView*) controlView;

	// Animation Optimization
- (void) setAnimationRect: (NSRect) rect;
- (void) addAnimationsToGroup: (ATAnimationGroup*) animGroup;

	// Setting the State with an Animation
- (void) setState: (int) newState animationType: (LCDCellAnimation) animType;

	// Setting the Value with an Animation
- (void) setStringValue: (NSString*) newString animationType: (LCDCellAnimation) animType;
- (void) setIntValue: (int) newValue animationType: (LCDCellAnimation) animType;
@end




