/* HotkeyController */

#import <Cocoa/Cocoa.h>

#define __CARBONSOUND__
#include <Carbon/Carbon.h>

typedef struct _hotkey {
	EventHotKeyRef   handle;
	
	id				 target;
	SEL              selector;
    
    int              keycode;
    NSInteger              modifiers;
    EventHotKeyID    myid;
    BOOL             enabled;
}  HotkeyInfo;

@interface HotkeyController : NSObject
{
	int                      count;
    BOOL                     disabled;

	NSMutableDictionary     *bindings;
    NSMutableDictionary     *keyToCode;
    NSMutableDictionary     *codeToKey;
}

+ (id)sharedInstance;

- (id)init;
- (void)initHotKeys;

/* Keycode to keystring */
- (NSString *)stringForKey:(int)keycode withModifiers:(int)modifiers;
- (NSString *)stringForModifiers:(int)modifiers;
- (NSString *)stringForCode:(int)keycode;
- (int)codeForString:(NSString *)string;

/* Enable and disable single hotkey */
- (void)enableHotkey: (HotkeyInfo *)info firstTime:(BOOL)firstflag;
- (void)disableHotkey:(HotkeyInfo *)info;

/* Enable and disable all hotkeys */
- (void)enable;
- (void)disable;

- (void)addHotkey:(NSString *)key withModifiers:(NSUInteger)modifiers target:(id)obj selector:(SEL)sel;
- (void)hotkeyEvent:(EventHotKeyRef)handle;

@end
