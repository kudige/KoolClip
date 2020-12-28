#include "KoolClip.h"
#import "AboutPanel.h"

@implementation AboutPanel

- (IBAction)done:(id)sender
{
       debug_printf ("%s called by %s\n", __FUNCTION__, [[sender description] UTF8String]);
       [self performClose:sender];
       [NSApp stopModal];
}

- (IBAction)visitblog:(id)sender
{
    [[NSWorkspace sharedWorkspace] 
        openURL:[NSURL URLWithString:URLBlog]];
}

@end
