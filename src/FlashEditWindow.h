/* FlashEditWindow */

#import <Cocoa/Cocoa.h>

@interface FlashEditWindow : NSWindow
{
    id      flashDelegate;
	NSPoint initialLocation;
    NSBox  *box;
}

- (id)initWithFrame:(NSRect)frame 
             target:(id)obj;

@end
