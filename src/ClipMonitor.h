/* ClipMonitor */

#import <Cocoa/Cocoa.h>
#import "ClipItem.h"

@interface ClipMonitor : NSResponder
{
    NSInteger               changeCount;
    ClipItem         *clipItem;
    NSPasteboard     *clip;
    NSTimer          *timer;

    NSMutableArray   *listeners;
}

- (id)init;
- (void)awakeFromNib;

- (NSInteger)changeCount;
- (void)setChangeCount:(NSInteger)count;

/*
 * Pause and resume monitoring clipboard.
 * Looses events during this period.
 */
- (IBAction)pause:(id)sender;
- (IBAction)resume:(id)sender;

/*
 * Get the current clip item.
 */
- (ClipItem *)clipItem;

/*
 * Paste an item into the clipboard
 */
- (void)setItem:(ClipItem *)clipItem;

/*
 * Notify the listener when clipboard changes:
 * Sends a clipChanged:(ClipItem) message
 */
- (void)registerListener:(id)target;

/*
 * Internal to clip monitor - trigger polling the clipboard for changes
 */
- (ClipItem *)checkClipboardForChanges;
- (void)checkClipboardForChangesWithTimer:(NSTimer *)timer;

@end
