/* DesktopManager -- A virtual desktop provider for OS X
 *
 * Copyright (C) 2003, 2004 Richard J Wareham <richwareham@users.sourceforge.net>
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by the Free 
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 675 
 * Mass Ave, Cambridge, MA 02139, USA.
 */

#import "NotificationView.h"
#import "ClipController.h"

@implementation NotificationView

const float kRoundedRadius = 25;
extern void *CGSReadObjectFromCString(char*);
//extern char *CGSUniqueCString(char*);
extern void *CGSSetGStateAttribute(void*,char*,void*);
//extern void *CGSReleaseGenericObj(void*);

- (id)initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];
        
    clipItem = NULL;
    background = YES;
	return self;
}

- (void)setBackground:(BOOL)value {
    background = value;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	[super dealloc];
}

- (void)setItem:(ClipItem *)item {
    clipItem = item;
    [self setNeedsDisplay: YES];
}

- (ClipItem *)item {
    return clipItem;
}

- (void)drawRect:(NSRect)rect
{
    NSSize size = [self bounds].size;
#if 0
    void *graphicsPort;
    void *shadowValues=nil;
#endif
    CGContextRef context = NULL;

    if (background) {
      CGRect pageRect;
      context = 
        (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
 
      pageRect = CGRectMake(0, 0, rect.size.width, rect.size.height);

      CGContextBeginPage(context, &pageRect);

      CGContextSetRGBFillColor(context, 
			       [UD floatForKey:DefaultsFlashColorRed], 
			       [UD floatForKey:DefaultsFlashColorGreen], 
			       [UD floatForKey:DefaultsFlashColorBlue], 
			       [UD floatForKey:DefaultsFlashAlpha]);

      // Draw rounded rectangle.
      CGContextBeginPath(context);
      CGContextMoveToPoint(context,0,kRoundedRadius);
      CGContextAddArcToPoint(context, 0,0, kRoundedRadius,0, kRoundedRadius);
      CGContextAddLineToPoint(context, size.width - kRoundedRadius, 0);
      CGContextAddArcToPoint(context, size.width,0, 
			     size.width,kRoundedRadius, kRoundedRadius);
      CGContextAddLineToPoint(context, size.width , size.height - kRoundedRadius);
      CGContextAddArcToPoint(context, size.width,size.height, 
			     size.width - kRoundedRadius,size.height, kRoundedRadius);
      CGContextAddLineToPoint(context, kRoundedRadius,size.height);
      CGContextAddArcToPoint(context, 0,size.height, 
			     0,size.height-kRoundedRadius, kRoundedRadius);
      CGContextClosePath(context);
      CGContextFillPath(context);

#if 0
      /* Shadow Magic */
      [NSGraphicsContext saveGraphicsState];
      NSString *shadowValuesString = [NSString stringWithFormat: 
						 @"{ Style = Shadow; Height = %d; Radius = %d; Azimuth = %d; Ka = %f; }",
					       1, 3, 90, 0.0];
      shadowValues = CGSReadObjectFromCString((char*) [shadowValuesString UTF8String]);
      graphicsPort = [[NSGraphicsContext currentContext] graphicsPort];
      CGSSetGStateAttribute(graphicsPort, CFSTR("Style"), shadowValues);
#endif
    }

	
    /* =============== Start of Our Drawing =============================== */
    if (!clipItem)
        return;

    //    int fontSize = 12;
    int imageFontSize = 12;

    NSPoint  logoImagePoint;
    NSPoint  imageInfoPoint;
    float    ImageInfoY = 0;

    //    NSRect   mainTextRect;
    //    NSRect   imageInfoRect;

    /* Draw Logo image */
    NSImage *logo= [CC flashIcon];

    logoImagePoint.x = (size.width - [logo size].width) / 2.0;
    logoImagePoint.y = 0.9 * size.height - [logo size].height / 2.0;

    [[CC flashIcon] 
        compositeToPoint: logoImagePoint 
        operation: NSCompositeSourceOver];

    /* Draw Data Image */
    NSImage *dataImage = [clipItem image];

    NS_DURING
    if (dataImage) {
        NSPoint  mainImagePoint;
        mainImagePoint.x = (size.width  - [dataImage size].width)/2;
        ImageInfoY = mainImagePoint.y = 
            (size.height - [dataImage size].height)/2;
        
        [dataImage compositeToPoint:mainImagePoint 
                   operation: NSCompositeSourceOver];
    } else {
        /* Draw Main Text */
        NSAttributedString *mainText = [clipItem text];
        //NSAttributedString *mainText = [[[NSAttributedString alloc]
        //initWithString:
        //                                                [[clipItem text] string]]
        //                                           autorelease];

        if (mainText) {
            NSPoint textPoint;
            NSSize  textSize = [mainText size];

            if (textSize.width > size.width * 0.7) {
                textSize.width = size.width * 0.7;
            }

            if (textSize.height > size.height * 0.7) {
                textSize.height = size.height * 0.7;
            }

            /* Text attributes for Main Text */            
            textPoint.x = (size.width - textSize.width)/2;
            ImageInfoY = textPoint.y = (size.height - textSize.height)/2;
            
            //            NSSize textBounds;
            //            textBounds.width = size.width * 0.7;
            //            textBounds.height = size.height * 0.7;
            
            NSRect textRect;
            textRect.origin = textPoint;
            textRect.size   = textSize;
            
            [mainText drawInRect: textRect];
        }
    }
    NS_HANDLER
        /* Do nothing: Hack for the exception 
         * "[NSFlippableView textStorage]: selector not recognized"
         * that seems to be raised if the drawing is beyond
         * the screen.
         *
         * Just polite to handle this.
         */
    NS_ENDHANDLER

    NSString     *imageInfo = [clipItem imageInfo];
    if (imageInfo) {
        /* Text Attribute for Image Info */
        NSDictionary *attr = [NSDictionary 
                                 dictionaryWithObjectsAndKeys:
                                     [NSColor redColor], 
                                 NSForegroundColorAttributeName,
                                 [NSFont boldSystemFontOfSize: imageFontSize], 
                                 NSFontAttributeName,
                                 nil];
        
        NSSize textSize = [imageInfo sizeWithAttributes:attr];
        
        imageInfoPoint.x = (size.width - textSize.width)/2;
        imageInfoPoint.y = ImageInfoY - 2*textSize.height;
        if (imageInfoPoint.x < 0)
            imageInfoPoint.x = 0;
        [imageInfo drawAtPoint: imageInfoPoint withAttributes: attr];
    }
    

    /* ===================== End Of Our Drawing ===================== */
    // Undo shadow magic
    if (background) {
      [NSGraphicsContext restoreGraphicsState];
#if 0
      CFRelease(shadowValues);
#endif
	CGContextEndPage(context);

	CGContextFlush(context);
    }
}

@end
