/* PrefsPanel */

#import <Cocoa/Cocoa.h>

#include "KoolClip.h"
#import "FlashEditWindow.h"
#import "HotkeyInputWindow.h"
#import "HotkeyTarget.h"

@interface PrefsPanel : NSPanel
{
    IBOutlet id tabView;
    IBOutlet id flashAlpha;
    IBOutlet id flashColor;
    IBOutlet id flashDelay;
    IBOutlet id flashHeight;
    IBOutlet id flashWidth;
    IBOutlet id historySize;
    IBOutlet id iconFrozen;
    IBOutlet id iconNormal;
    IBOutlet id defaultIcons;
    IBOutlet id showInMenuBar;
    IBOutlet id textInMenuBar;
    IBOutlet id urlKBMB;
    IBOutlet id urlKeywords;
    IBOutlet id urlMaxdata;
    IBOutlet id urlPreview;

    /* Hot Keys */
    IBOutlet id keyPrev;
    IBOutlet id ctlPrev;
    IBOutlet id optPrev;
    IBOutlet id cmdPrev;

    IBOutlet id keyNext;
    IBOutlet id ctlNext;
    IBOutlet id optNext;
    IBOutlet id cmdNext;

    IBOutlet id keyCurr;
    IBOutlet id ctlCurr;
    IBOutlet id optCurr;
    IBOutlet id cmdCurr;

    IBOutlet id keyLock;
    IBOutlet id ctlLock;
    IBOutlet id optLock;
    IBOutlet id cmdLock;

    IBOutlet id keyPrefs;
    IBOutlet id ctlPrefs;
    IBOutlet id optPrefs;
    IBOutlet id cmdPrefs;

    IBOutlet id keySearch;
    IBOutlet id ctlSearch;
    IBOutlet id optSearch;
    IBOutlet id cmdSearch;

    IBOutlet id keyClear;
    IBOutlet id ctlClear;
    IBOutlet id optClear;
    IBOutlet id cmdClear;

    IBOutlet id keyGoogle;
    IBOutlet id ctlGoogle;
    IBOutlet id optGoogle;
    IBOutlet id cmdGoogle;

    IBOutlet id keyQuit;
    IBOutlet id ctlQuit;
    IBOutlet id optQuit;
    IBOutlet id cmdQuit;

    IBOutlet id unsavedChanges;

    IBOutlet id cancelButton;
    IBOutlet id applyButton;

    /* Other preference state variables */
    BOOL        iconEnabled;
    NSInteger   textType;

    NSPoint     flashOrigin;

    BOOL        boolUrlPreview;
    BOOL        boolUrlKeywords;
    NSInteger   urlMaxbytes;

    FlashEditWindow   *flashGuide;
    HotkeyInputWindow *hotwin;

    id          currHotkey;
    BOOL        dirty;
}

/*
 * Populate the controls from the user defaults.
 */
- (void)refresh;
- (void)setDirty:(BOOL)dirty;

/*
 * Return the current preferences as a dictionary.
 */
- (NSDictionary *)preferences;

/*
 * UI Actions
 */
- (IBAction) uiChanged:(id)sender;

- (IBAction) apply:(id)sender;

- (IBAction) cancel:(id)sender;

- (IBAction) resetIcons:(id)sender;

- (IBAction) support:(id)sender;

/*
 * Called when a hotkey button is pressed.
 */
- (IBAction) hotPress:(id)sender;

/* Flash Guide */
- (void)startFlashGuide;

- (void)endFlashGuide;

- (void)updateFlashGuide;

/* Delegate for tab View */
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

/* MyDelegate for flash guide */
- (void)flashUpdated:(id)sender;

@end
