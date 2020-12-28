#import "SearchPanel.h"

#include "KoolClip.h"

@implementation SearchPanel

- (void)awakeFromNib {
    debug_printf("%s called\n", __FUNCTION__);
    [self setFrameUsingName:DefaultsFrameSearch];

    [self setSpecial];
    [self setDelegate:CC];
    [table setDataSource:[CC dataSource]];

    notificationView = [[NotificationView alloc] 
                           initWithFrame:[box borderRect] ];
    [notificationView setItem:nil] ;
    [notificationView setBackground:NO];

    [box setContentView:(NSView *)notificationView];

    selectedItem = currentItem = nil;
    nItems = -1;
}

// Initialize the table view to display a checkbox button
- (void)setSpecial {
    NSTableColumn *desiredColumn;
    
    NSButtonCell *cell;
    cell = [[NSButtonCell alloc] init];
    [cell setButtonType:NSSwitchButton];
    [cell setTitle:@""];
    [cell setAction:@selector(toggleLocked:)];
    [cell setTarget:self];
    
    desiredColumn = [table tableColumnWithIdentifier:@"locked"];
    [desiredColumn setDataCell:cell];
    [cell release];
}

-(IBAction)toggleLocked:(id)sender
{
    NSInteger sel = [table selectedRow];

    if (sel < 0)
        return;

    [[(ClipMenu *)[CC dataSource]
        tableView:table
        objectForRow:sel] toggleLocked];
}

- (void)selectAndClose:(id)sender {
    //    debug_printf("%s called\n", __FUNCTION__);
    
    NSInteger sel = [table selectedRow];

    if (sel < 0)
        return;

    [CC clipSelected:[(ClipMenu *)[CC dataSource]
                         tableView:table
                         objectForRow:sel]];
    [self performClose:sender];
}

- (void)performClose:(id)sender {
    //    debug_printf("%s called\n", __FUNCTION__);

    [self saveFrameUsingName:DefaultsFrameSearch];

	[NSApp stopModal];
    
    [super performClose:sender];
}

- (void)refresh {
    [(ClipMenu *)[CC dataSource] refreshSearch];
    [searchField setStringValue:[(ClipMenu *)[CC dataSource] searchString]];

    selectedItem = (ClipItem *)[(ClipMenu *)[CC dataSource] getSelected];
    //debug_printf ("%s selectedItem @ %p\n", __FUNCTION__, selectedItem);
    nItems = [(ClipMenu *)[CC dataSource] nItems];

    debug_printf ("%s nItems IS %d\n", __FUNCTION__, nItems);
    [table reloadData];
    [self tableViewSelectionDidChange:nil];
}

- (void)setItem:(ClipItem *)item {
    if (notificationView) {
        [notificationView setItem:item];
    }
}

/* Delegate for tableView */
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger sel = [table selectedRow];

    if (sel < 0)
        return;

    currentItem  = [(ClipMenu *)[CC dataSource] 
                       tableView:table 
                       objectForRow:sel];
    //debug_printf("%s sel %d currentItem @ %p notification @ %p\n", 
    //__FUNCTION__, sel, currentItem, aNotification);

    [notificationView setItem:currentItem];
}

- (void)tableView:(NSTableView *)aTableView 
  willDisplayCell:(id)aCell
   forTableColumn:(NSTableColumn *)aTableColumn 
              row:(int)rowIndex 
{
    ClipItem *item = [(ClipMenu *)[CC dataSource] 
                         tableView:table 
                         objectForRow:rowIndex];
    //debug_printf ("%s rowIndex %d item @ %p\n", __FUNCTION__, rowIndex, item);
    if (item) {
#if 0
        if (item == currentItem) {
            //debug_printf ("Found current item\n");
            selectedRow = rowIndex;
            
            [table selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow]
                   byExtendingSelection:NO];
        } else {
        }

        if (item == selectedItem) {
            [table selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex]
                   byExtendingSelection:NO];

            //            debug_printf ("Found selected item\n");
            //            [aCell setHighlighted:YES];
            //[aCell setControlTint:NSGraphiteControlTint];
            //            [aCell setBordered:YES];
        } else {
            //            [aCell setHighlighted:NO];
            //[aCell setControlTint:NSDefaultControlTint];
            //[aCell setBordered:NO];
        }
#endif
    }
}

- (IBAction)textChanged:(id)sender {
    [(ClipMenu *)[CC dataSource] setSearchString:[searchField stringValue]];
    //    [searchField selectText:self];
    //debug_printf ("%s called: text %s\n", __FUNCTION__, 
    //          [[searchField stringValue] UTF8String]);

   [self refresh];
}

- (void)sendEvent : (NSEvent *) theEvent {
    
    if ([theEvent type] == NSKeyDown) {
        unsigned short keyCode = [theEvent keyCode];
        unsigned int   modifierFlags = [theEvent modifierFlags] & 
            (NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask);

#if 0
        debug_printf ("%s called type %d code %d modflags %d\n", 
                __FUNCTION__, [theEvent type],
                keyCode, modifierFlags);
#endif

        /* Send arrow keys to the table to move the selection
         * up and down
         */
        if (modifierFlags == 0 && (keyCode == 125 || keyCode == 126)) {
            [self makeFirstResponder:table];
            [super sendEvent: theEvent];
            [self makeFirstResponder:searchField];

            theEvent = nil; /* Handled */
        }

        /* Ctrl-W to close the window */
        if (modifierFlags == NSCommandKeyMask && keyCode == 13) {
            [self performClose:self];
            theEvent = nil; /* Handled */
        }

        /* Enter to select the window */
        if (modifierFlags == 0 && keyCode == 36) {
            [self selectAndClose:self];
            theEvent = nil; /* Handled */
        }
    }
    if (theEvent)
        [super sendEvent: theEvent];
}

@end
