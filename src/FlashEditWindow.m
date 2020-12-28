#import "FlashEditWindow.h"
#include "KoolClip.h"

@implementation FlashEditWindow
- (id)initWithFrame:(NSRect)frame target:(id)obj
{
    NSRect contentRect = frame;

    contentRect.origin.x = contentRect.origin.y = 0;
    NSWindow* flashGuide = [super 
                               initWithContentRect:contentRect 
                               styleMask: (NSTitledWindowMask|NSResizableWindowMask)
                               backing: NSBackingStoreBuffered
                               defer:TRUE];
	
    [flashGuide setHasShadow: YES];

    NSRect rect = contentRect;

    /* Create the box inside */
    box = [[NSBox alloc] initWithFrame:rect];
    [box setTitle:HelpFlashGuide];
    [box setBorderType:NSNoBorder];
    //        [box setTitleFont:[NSFont userFontOfSize:18]];
    [box setTitleFont:[NSFont boldSystemFontOfSize:18]];
    [flashGuide setContentView:box];
    
    /* Position the frame */
    [flashGuide setFrame:frame display:YES];
    
    [flashGuide setLevel: kCGUtilityWindowLevel ];
    [flashGuide makeKeyAndOrderFront:self];
    [flashGuide orderFrontRegardless];

    
    /* Setup the target */
    flashDelegate = obj;
    [flashGuide setDelegate:obj];
    
	debug_printf ("%s created @ %p\n", __FUNCTION__, flashGuide);
    return (id)flashGuide;
}

- (BOOL) canBecomeKeyWindow
{
	debug_printf ("canBecomeKeyWindow:\n");
    return YES;
}

- (void)dealloc {
    if (box) {
        [box release];
    }
    [super dealloc];
}

@end
