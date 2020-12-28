/* HotkeyInputWindow */

#import <Cocoa/Cocoa.h>

@interface HotkeyInputWindow : NSWindow
{
    id             hotkeyTarget;
    NSString      *textInfo;
    NSBox         *box;
    NSPoint        initialLocation;
}

- (id)initWithTarget:(id)obj;

- (void)setTitle:(NSString *)text;

@end
