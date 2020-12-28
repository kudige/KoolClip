/* ClipController */

#import <Cocoa/Cocoa.h>
#import "ClipMenu.h"
#import "ClipItem.h"
#import "ClipMonitor.h"
#import "SearchPanel.h"
#import "PrefsPanel.h"

@interface ClipController : NSResponder
{
    IBOutlet ClipMonitor *monitor;
    IBOutlet ClipMenu    *theMenu;
    IBOutlet id           searchPanel;
	IBOutlet id			  hotkeys;
    
    PrefsPanel           *prefsPanel;
    NSWindow             *notificationWindow;
    NSTimer              *notificationTimer;
	BOOL                  hideNotification;

    NSImage              *iconNormal;
    NSImage              *iconFrozen;
}

+ (id)sharedInstance;

- (id)init;
- (id)hotkeys;

/*
 * Application Icons
 */
- (void)setIconNormal:(NSImage *)icon;
- (void)setIconFrozen:(NSImage *)icon;

- (id)unlockedIcon;
- (id)lockedIcon;
- (id)flashIcon;


- (void)awakeFromNib;

/* Archiving */
- (void)saveObject:(id)object forKey:(NSString *)keyName;
- (id)loadObjectForKey:(NSString *)keyName;

/* Actions */
- (IBAction)clear:(id)sender;
- (IBAction)disable:(id)sender;
- (IBAction)enable:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)load:(id)sender;
- (IBAction)setup:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)disableHotkeys:(id)sender;
- (IBAction)enableHotkeys:(id)sender;
- (IBAction)search:(id)sender;
- (IBAction)support:(id)sender;
- (IBAction)google:(id)sender;

- (void)registerHotkeys;

/* Call backs */
- (void)flashItem:(id)clipItem;
- (void)clipSelected:(id)clipItem;
- (void)clipChanged:(ClipItem *)item;
- (void)handleNextClip;
- (void)handlePrevClip;
- (void)prefsChanged:(NSDictionary *)newPrefs;

//- (void)menuView;

- (void) hideNotificationWindow;
- (void) showNotificationWindow:(NSAttributedString *)message 
						forItem:(ClipItem *)item
                        forTime:(NSTimeInterval)howLong;

/* Returns the data source object for the clip history */
- (ClipMenu *)dataSource;

/* Delegate for the SearchPanel */
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidBecomeKey:(NSNotification *)aNotification;

@end
