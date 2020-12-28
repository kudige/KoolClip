/* ClipMenu */

#import <Cocoa/Cocoa.h>
#import "AppleMenu.h"
//#import "ClipMenuItem.h"

#include "KoolClip.h"

@interface ClipMenu : AppleMenu
{
    BOOL              locked;

#ifdef WANT_TEXT_ON
    id                textOn;
#endif
    NSString         *searchString;
    NSMutableArray   *searchArray;

    /* Menu items */
    id                about;
    id                prev;
    id                next;
    id                prefs;
    id                search;
    id                lock;
    id                clear;
    id                quit;
    id                appreciate;    
}

- (id)init;
- (void)awakeFromNib;
- (void)lock;

- (void)initMenuItems;
- (void) refreshMenuText;

- (BOOL)frozen;
- (void)toggleText;
- (AppleMenuItem *)nextClip;
- (AppleMenuItem *)prevClip;
- (int)nItems;
- (int)nUnlockedItems;
- (int)nLockedItems;

/*
 * Remove the oldest clip 
 */
- (void)popFirstClip;

/* For serializing the clip history 
 *
 * Returns all the clips in an array, oldest one at index 0
 */
- (NSMutableArray *)clipArray;

/* Search related data operations */
- (void)setSearchString:(NSString *)string;
- (NSString *)searchString;
- (NSMutableArray *)searchArray;
- (void)refreshSearch;

/* Data source for the search view */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView 
       objectValueForTableColumn:(NSTableColumn *)aTableColumn 
       row:(int)rowIndex;
- (id)tableView:(NSTableView *)aTableView objectForRow:(NSInteger)rowIndex;

@end
