#define __CARBONSOUND__
#include <Carbon/Carbon.h>

#import "CCApplication.h"
#import "HotkeyController.h"
#import "ClipController.h"

//extern void hotkeyCallback(EventHotKeyRef code);

enum {
    // NSEvent subtypes for hotkey events (undocumented)
    kEventHotKeyPressedSubtype = 6,
    kEventHotKeyReleasedSubtype = 9,
};


@implementation CCApplication
+ (void)initialize{
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    int modifiers = (controlKey|cmdKey);
    NSDictionary *appDefaults = 
        [[NSDictionary alloc] 
            initWithObjectsAndKeys:
                @"yes",  DefaultsShowIcon,

            [NSNumber numberWithInt:TEXT_TYPE_COUNT],
            DefaultsTextType,
            
            [NSNumber numberWithBool:NO],
            DefaultsShowExtendedText,
            
            /* Saved State */
            [NSNumber numberWithInt:DEFAULT_HISTORY_SIZE],
            DefaultsHistorySize,

            [NSArray array],
            DefaultsClips,

            [NSNumber numberWithInt:-1],
            DefaultsSelection,

            [NSNumber numberWithBool:NO],
            DefaultsFrozen,

            [NSNumber numberWithInt:0],
            DefaultsChangeCount,

            /* Flash */
            [NSNumber numberWithInt:FLASH_ORIGINX],
            DefaultsFlashX,

            [NSNumber numberWithInt:FLASH_ORIGINY],
            DefaultsFlashY,

            [NSNumber numberWithInt:FLASH_WIDTH],
            DefaultsFlashWidth,

            [NSNumber numberWithInt:FLASH_HEIGHT],
            DefaultsFlashHeight,

            [NSNumber numberWithFloat:FLASH_ALPHA],
            DefaultsFlashAlpha,

            [NSNumber numberWithFloat:FLASH_DELAY],
            DefaultsFlashDelay,

            [NSNumber numberWithFloat:FLASH_COLOR_RED],
            DefaultsFlashColorRed,

            [NSNumber numberWithFloat:FLASH_COLOR_BLUE],
            DefaultsFlashColorBlue,

            [NSNumber numberWithFloat:FLASH_COLOR_GREEN],
            DefaultsFlashColorGreen,

            /* URL related */
            @"no",
            DefaultsUrlPreview,

            @"no",
            DefaultsUrlKeywords,

            [NSNumber numberWithInt:URL_MAXDATA],
            DefaultsUrlMaxData,

            /* HotKeys */
            @"[",
            DefaultsKeyPrev,

            @"]",
            DefaultsKeyNext,

            @"=",
            DefaultsKeyCurr,

            @"F",
            DefaultsKeyLock,

            @"P",
            DefaultsKeyPrefs,

            @"S",
            DefaultsKeySearch,

            @"C",
            DefaultsKeyClear,

            @"Q",
            DefaultsKeyQuit,

            @"G",
            DefaultsKeyGoogle,

            [NSNumber numberWithInt:modifiers],
            DefaultsModPrev,

            [NSNumber numberWithInt:modifiers],
            DefaultsModNext,

            [NSNumber numberWithInt:modifiers],
            DefaultsModCurr,

            [NSNumber numberWithInt:modifiers],
            DefaultsModLock,

            [NSNumber numberWithInt:modifiers],
            DefaultsModPrefs,

            [NSNumber numberWithInt:modifiers],
            DefaultsModSearch,

            [NSNumber numberWithInt:modifiers],
            DefaultsModClear,

            [NSNumber numberWithInt:modifiers],
            DefaultsModQuit,

            [NSNumber numberWithInt:modifiers],
            DefaultsModGoogle,

            nil];

    NSEnumerator *keys = [appDefaults keyEnumerator];
    id            key, value;

    while (key = [keys nextObject]) {
        value = [appDefaults objectForKey:key];
        if ([UD objectForKey:key] == nil) {
            [UD setObject:value forKey:key];
        }
    }

    //    [defaults registerDefaults:appDefaults];
    debug_printf ("%s setting defaults\n", __FUNCTION__);
}

/*
 * Init routine 
 */
- (void)awakeFromNib {
    debug_printf ("%s called\n", __FUNCTION__);
    [self setDelegate:CC];
}


- (void)sendEvent : (NSEvent *) theEvent {
    if(([theEvent type] == NSSystemDefined) && 
       ([theEvent subtype] == kEventHotKeyPressedSubtype)) {
        // Dispatch hotkey press notification.
        EventHotKeyRef hotKeyRef = (EventHotKeyRef) [theEvent data1];
		
		[[HotkeyController sharedInstance] hotkeyEvent:hotKeyRef];
//		hotkeyCallback(hotKeyRef);
    }

    [super sendEvent: theEvent];
}

@end
