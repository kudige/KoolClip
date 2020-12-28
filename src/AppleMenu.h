/* AppleMenu */

#import <Cocoa/Cocoa.h>
#import "AppleMenuItem.h"

#include "KoolClip.h"

@interface AppleMenu : NSMenu
{
    int           itemCount;
	int           baseCount;
    NSStatusBar  *theBar;
    NSStatusItem *theItem;
//    NSMenu       *theMenu;
	AppleMenuItem *selectedItem;

    NSImage       *ourIcon;
    NSString      *ourText;
}

+ (id)sharedInstance;

- (id)init;
- (id)addMenuItem:(AppleMenuItem *)aitem;
- (void)clear;
- (void)refresh;

/*
 * Enable and disable KoolClip from the menu bar */
- (void)enable;
- (void)disable;

/* Change the icon and text in the menubar */
- (void)setIcon:(NSImage *)icon;
- (void)setText:(NSString *)text;

- (void)countChanged;
- (IBAction)unselectall:(id)sender;
- (void)select:(AppleMenuItem *)aitem;
- (void)setSelected:(AppleMenuItem *)aitem;
- (AppleMenuItem *)getSelected;

- (id)myInsertItem:(id)item atIndex:(int)idx;
- (id)insertItemWithTitle:(NSString *)aString 
                   action:(SEL)aSelector 
            keyEquivalent:(NSString *)keyEquiv 
                  atIndex:(unsigned int)index 
               withTarget:(id)target;

@end
