/* AppleMenuItem */

#import <Cocoa/Cocoa.h>

@interface AppleMenuItem : NSObject
{
    NSMenuItem *menuItem;
    id          menu;
}

- (id)init;
- (void)setMenuItem:(NSMenuItem *)menuItem;
- (void)setMenu: (id)menuID;
- (NSMenuItem *)menuItem;

/* Abstract messages */
- (NSAttributedString *)text;
- (NSString *)title;
- (NSAttributedString *)attributedTitle;
- (NSImage *) image;
- (NSImage *) icon;
- (void)select:(id)menuitem;
- (int)getCount;

@end
