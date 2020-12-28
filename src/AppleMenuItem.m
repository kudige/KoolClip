#include "KoolClip.h"
#import "AppleMenuItem.h"

@implementation AppleMenuItem
- (id)init
{
    menuItem = NULL;
    menu     = NULL;
	return self;
}

- (void)setMenuItem:(NSMenuItem *)mItem
{
    menuItem = mItem;
}

- (void)setMenu: (id)menuID {
    menu = menuID;
}

- (NSMenuItem *)menuItem {
    return menuItem;
}

/* Abstract Methods */
- (NSAttributedString *)text {
    return nil;
}

- (NSString *)title {
    return nil;
}

- (NSAttributedString *)attributedTitle {
    return nil;
}

- (NSImage *) image {
    return nil;
}

- (NSImage *) icon {
    return nil;
}

- (void)select:(id)menuitem {
    debug_printf ("Yeeks %s called self @ %p\n", __FUNCTION__, self);
}

- (void)selectNoFlash:(id)menuitem {
    debug_printf ("Yeeks %s called self @ %p\n", __FUNCTION__, self);
}

- (int)getCount {
    return -1;
}

@end
