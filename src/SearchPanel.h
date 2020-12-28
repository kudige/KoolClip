/* SearchPanel */

#import <Cocoa/Cocoa.h>
#import "NotificationView.h"
#import "ClipController.h"
#import "ClipItem.h"

@interface SearchPanel : NSPanel
{
    IBOutlet id searchField;
    IBOutlet id searchList;
    IBOutlet id table;
    IBOutlet id box;
    IBOutlet id textView;

    NotificationView *notificationView;
    ClipItem         *selectedItem; /* Global Selection */
    ClipItem         *currentItem;  /* Current in Table View */

    /* Keep the same row selected even when searching different things */
    int               selectedRow;  
    int               nItems;
}

- (void)setSpecial;
- (IBAction)textChanged:(id)self;
- (void)awakeFromNib;
- (void)performClose:(id)sender;
- (void)refresh;
- (void)setItem:(ClipItem *)item;

/* Delegate for tableView */
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

- (void)sendEvent : (NSEvent *) theEvent;
@end
