#include "ImageUtilities.h"

#ifdef QUINN
#import "NSImage-QuinnExtensions.h"
#else
#import "NSImage-Extensions.h"
#endif

CGImageRef CreateCGImageFromNSImage( NSImage* image )
// Creates a CG image from the specified NSImage. The caller is responsible for CGImageRelease()ing the
// returned image ref. Returns NULL on error.
{
	NSBitmapImageRep* bitmapRep;
	
	if ( bitmapRep = (NSBitmapImageRep*)[image representationOfClass:[NSBitmapImageRep class]] ) {
		CGImageRef imageRef = CreateCGImageFromNSBitmapImageRep( bitmapRep ); // shortcut
		if ( imageRef ) return imageRef; // may return NULL in some cases, for unknown reasons
	}
	
		// create a bitmap graphics context where we will draw the image
		// (always RGBA color space, 4 bytes per pixel)
	NSSize imgSize = [image size];
	int bitmapBytesPerRow = 4 * imgSize.width;
	int bitmapByteCount = bitmapBytesPerRow * imgSize.height;
	int bitsPerComponent = 8;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB ); 
	
	void* bitmapData = malloc( bitmapByteCount );
	if ( !bitmapData ) {
		NSLog( @"CreateCGImageFromNSImage() could not allocate memory for bitmap." );
		return NULL;
	}
	
	CGContextRef context = CGBitmapContextCreate( bitmapData, imgSize.width, imgSize.height,
		bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast );
	if ( !context ) {
		free( bitmapData );
		CGColorSpaceRelease( colorSpace ); 
		NSLog( @"CreateCGImageFromNSImage() failed to create graphics context." );
		return NULL;
	}
	
		// draw the image to the context
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext* gContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
	[NSGraphicsContext setCurrentContext:gContext];
	
	NSRect rect = NSMakeRect( 0.0, 0.0, imgSize.width, imgSize.height );
	[[NSColor clearColor] set];
	NSRectFill( rect );
	[image drawAtPoint:NSZeroPoint fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	
	[NSGraphicsContext restoreGraphicsState];
	
		// create a CG image from the bitmap data (copies the data)
	CGImageRef imageRef = CGBitmapContextCreateImage( context );
	if ( !imageRef ) NSLog( @"CreateCGImageFromNSImage() failed to create CG image." );
	
	CGContextRelease( context );
	CGColorSpaceRelease( colorSpace ); 
	free( bitmapData );
	
	return imageRef;
}

CGImageRef CreateCGImageFromNSBitmapImageRep( NSBitmapImageRep* imageRep )
// The caller is responsible for CGImageRelease()ing the returned image.
{
		// get the graphics context for the imageRep
	NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
	CGContextRef contextRef = [context graphicsPort];
	
		// create an image from the bitmap data (copies the data)
	CGImageRef imageRef = CGBitmapContextCreateImage( contextRef );
	
	return imageRef;
}

static void releaseBitmapData( void* info, const void* bitmapData, size_t size )
{
	free( (void*)bitmapData );
}

CGImageRef CreateCGImageMaskFromNSImage( NSImage* image )
// Creates a CG image mask from the specified NSImage, which should be a grayscale image. The caller is
// responsible for CGImageRelease()ing the returned image ref. Returns NULL on error.
{
		// create a bitmap graphics context where we will draw the image
		// (grayscale color space, 1 byte per pixel)
	NSSize imgSize = [image size];
	int bitmapBytesPerRow = 1 * imgSize.width;
	int bitmapByteCount = bitmapBytesPerRow * imgSize.height;
	int bitsPerComponent = 8;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericGray ); 
	
	void* bitmapData = malloc( bitmapByteCount );
	if ( !bitmapData ) {
		NSLog( @"CreateCGImageMaskFromNSImage() could not allocate memory for bitmap." );
		return NULL;
	}
	
	CGContextRef context = CGBitmapContextCreate( bitmapData, imgSize.width, imgSize.height,
		bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaNone );
	if ( !context ) {
		free( bitmapData );
		CGColorSpaceRelease( colorSpace ); 
		NSLog( @"CreateCGImageMaskFromNSImage() failed to create graphics context." );
		return NULL;
	}
	
		// draw the image to the context
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext* gContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
	[NSGraphicsContext setCurrentContext:gContext];
	
	NSRect rect = NSMakeRect( 0.0, 0.0, imgSize.width, imgSize.height );
	[[NSColor clearColor] set];
	NSRectFill( rect );
	[image drawAtPoint:NSZeroPoint fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	
	[NSGraphicsContext restoreGraphicsState];
	
		// create an image mask from the bitmap data (this is more complicated than creating a
		// CGImage, because there is no CGBitmapContextCreateImageMask() function)
	CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, bitmapData,
		bitmapByteCount, releaseBitmapData );
	
	CGImageRef imageRef = CGImageMaskCreate(
		imgSize.width, imgSize.height,	// image size
		bitsPerComponent,
		bitsPerComponent * 1,			// bits per pixel
		bitmapBytesPerRow,
		provider,						// data provider
		NULL,							// decode array
		TRUE							// shouldInterpolate
	);
	if ( !imageRef ) NSLog( @"CreateCGImageMaskFromNSImage() failed to create CG image mask." );
	
	CGContextRelease( context );
	CGColorSpaceRelease( colorSpace );
	CGDataProviderRelease( provider );
	
		// The bitmap data is released by releaseBitmapData(), which gets called when the data
		// provider is released (which in turn is retained by the image).
	
	return imageRef;
}




