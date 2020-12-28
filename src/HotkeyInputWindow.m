#import "ClipController.h"
#import "HotkeyController.h"
#import "HotkeyInputWindow.h"

@implementation HotkeyInputWindow


- (id)initWithTarget:(id)obj
{
    NSRect rect;
    rect.origin.x = rect.origin.y = 0; 
    rect.size.width  = 400;
    rect.size.height = 50;

    debug_printf ("%s called\n", __FUNCTION__);
    hotkeyTarget = obj;

    NSWindow* result = [super 
                           initWithContentRect:rect
                           styleMask: (NSTitledWindowMask|NSClosableWindowMask|NSResizableWindowMask)
                           backing: NSBackingStoreBuffered
                           defer:TRUE];
	
    [result setHasShadow: YES];

    box = [[NSBox alloc] initWithFrame:rect];
    [box setBorderType:NSNoBorder];
    [box setTitleFont:[NSFont boldSystemFontOfSize:12]];
    [box setTitle:HelpPressKeyCombo];

    [result setContentView:box];    
    [result setLevel: kCGUtilityWindowLevel ];
    [result makeKeyAndOrderFront:self];
    [result orderFrontRegardless];

    [result setDelegate:obj];
    NSRect frame = [result frame];
    frame.origin = [NSEvent mouseLocation];
    [result setFrame:frame display:YES];

    debug_printf ("%s created @ %p\n", __FUNCTION__, result);
    return (id)result;
}

- (void)setTitle:(NSString *)text {
    [box setTitle:text];
}

- (void)dealloc {
    debug_printf ("%s called\n", __FUNCTION__);

    if (box)
        [box release];

    [super dealloc];
}

- (void)sendEvent : (NSEvent *) theEvent {
    if ([theEvent type] == NSKeyDown) {
        NSUInteger flags = [theEvent modifierFlags];
        int keycode = [theEvent keyCode];

        /* ESC */
        if (keycode == 53) {
            [self performClose:self];
        } else {
            debug_printf ("%s key pressed [%s]\n", __FUNCTION__, [[theEvent characters] UTF8String]);
            debug_printf ("keycode %d flags %lu %s %s %s\n", [theEvent keyCode], flags,
                    (flags & NSAlternateKeyMask)?"opt":"",
                    (flags & NSControlKeyMask)?"ctl":"",
                    (flags & NSCommandKeyMask)?"cmd":"");

            int modifiers = 0;
            if (flags & NSAlternateKeyMask)
                modifiers |= optionKey;
            if (flags & NSControlKeyMask)
                modifiers |= controlKey;
            if (flags & NSCommandKeyMask)
                modifiers |= cmdKey;

            if ([hotkeyTarget respondsToSelector:@selector(hotkeyPressed:withModifiers:)]) {
                [hotkeyTarget performSelector:@selector(hotkeyPressed:withModifiers:)
                              withObject:[NSNumber numberWithInt:keycode]
                              withObject:[NSNumber numberWithInt:modifiers]];
            } else {
                debug_printf ("%s ERROR - hotkeyTarget does not respond to hotkeyPressed:withModifiers:\n",
                        __FUNCTION__);
            }
        }

    } else {
        [super sendEvent:theEvent];
    }
}

@end
