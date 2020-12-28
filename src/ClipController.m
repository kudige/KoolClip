#import "ClipController.h"
#import "HotkeyController.h"
#import "SearchPanel.h"

#include "NotificationView.h"

//const NSSize ClipItemFlashWindowSize = {FLASH_WIDTH, FLASH_HEIGHT};

ClipController *global = NULL;
int             firstTime = 1;

@implementation ClipController

+ (id)sharedInstance
{
    if (!global) {
        debug_printf ("%s: ERROR CC shared called too early ?? \n", __FUNCTION__);
        [NSApp terminate:self];
    }

    return global;
}

- (id)init {
    debug_printf ("%s: self @ %p global @ %p\n", __FUNCTION__, self, global);
    [super init];

    if (!global)
        global = self;

    notificationTimer  = NULL;
    notificationWindow = NULL;
	hideNotification   = FALSE;

    /* Load the icons */
    iconNormal = [[self loadObjectForKey:DefaultsRedIcon] retain];
    if (!iconNormal) {
        iconNormal = [[NSImage imageNamed: RED_ICON] retain];
    }

    iconFrozen = [[self loadObjectForKey:DefaultsBlueIcon] retain];
    if (!iconFrozen) {
        iconFrozen = [[NSImage imageNamed: BLUE_ICON] retain];
    }

    return self;
}

- (id)hotkeys {
    return hotkeys;
}

- (void)awakeFromNib {
    debug_printf ("%s: self @ %p searchPanel @ %p\n", __FUNCTION__, self,
            searchPanel);

    if (self != global) {
        debug_printf ("%s: ERROR SELF != GLOBAL\n", __FUNCTION__);
        [NSApp terminate:self];
    }

	if (firstTime) {
        searchPanel = nil;
		firstTime = 0;
        
        debug_printf ("ClipController awakeFromNib\n");
        /* We need to do this here to avoid race condition if ClipMenu
         * is created before us
         */
        [theMenu initMenuItems];
        
        
        
        [self load:self];
        
        /* Start receiving clip events */
        [monitor registerListener:self];
        
        /* start your engines */
        [monitor resume:self];
        
        [self registerHotkeys];
	}
}

- (void)registerHotkeys {
    /* ctrl-cmd-] */
    [hotkeys addHotkey:[UD stringForKey:DefaultsKeyPrev]
             withModifiers:[UD integerForKey:DefaultsModPrev]
             target:self
             selector:@selector(handleNextClip)];
    
    /* ctrl-cmd-[ */
    [hotkeys addHotkey:[UD stringForKey:DefaultsKeyNext] 
             withModifiers:[UD integerForKey:DefaultsModNext]
             target:self
             selector:@selector(handlePrevClip)];
    
    /* ctrl-cmd-= */
    [hotkeys addHotkey:[UD stringForKey:DefaultsKeyCurr] 
             withModifiers:[UD integerForKey:DefaultsModCurr]
             target:self
             selector:@selector(showCurrentClip:)];
    
    /* ctrl-cmd-q */
    [hotkeys addHotkey:[UD stringForKey:DefaultsKeyQuit] 
             withModifiers:[UD integerForKey:DefaultsModQuit]
             target:self
             selector:@selector(quit:)];
    
    /* ctrl-cmd-f */
    [hotkeys addHotkey:[UD stringForKey:DefaultsKeyLock] 
             withModifiers:[UD integerForKey:DefaultsModLock]
             target:theMenu
             selector:@selector(lock)];
    
    /* ctrl-cmd-c */
    [hotkeys addHotkey:[UD stringForKey:DefaultsKeyClear] 
             withModifiers:[UD integerForKey:DefaultsModClear]
             target:self
             selector:@selector(clear:)];
    
    /* ctrl-cmd-s */
    [hotkeys addHotkey:[UD stringForKey:DefaultsKeySearch] 
             withModifiers:[UD integerForKey:DefaultsModSearch]
             target:self
             selector:@selector(search:)];
    
    /* ctrl-cmd-p */
    [hotkeys addHotkey:[UD stringForKey:DefaultsKeyPrefs] 
             withModifiers:[UD integerForKey:DefaultsModPrefs]
             target:self
             selector:@selector(setup:)];

    /* ctrl-cmd-g */
    [hotkeys addHotkey:[UD stringForKey:DefaultsKeyGoogle] 
             withModifiers:[UD integerForKey:DefaultsModGoogle]
             target:self
             selector:@selector(google:)];

}


/*
 * Application Icon
 */
- (void)setIconNormal:(NSImage *)icon {
    if (iconNormal)
        [iconNormal autorelease];
    if (!icon)
        icon = [NSImage imageNamed: RED_ICON];
    iconNormal = [icon retain];
}

- (void)setIconFrozen:(NSImage *)icon {
    if (iconFrozen)
        [iconFrozen autorelease];
    if (!icon)
        icon = [NSImage imageNamed: BLUE_ICON];
    iconFrozen = [icon retain];
}

- (id)unlockedIcon{
    if (!iconNormal)
        iconNormal = [[NSImage imageNamed: RED_ICON] retain];
    return iconNormal;
}

- (id)lockedIcon{
    if (!iconFrozen)
        iconFrozen = [[NSImage imageNamed: BLUE_ICON] retain];
    return iconFrozen;
}

- (id)flashIcon{
    return [NSImage imageNamed: RED_ICON];
}


- (IBAction)clear:(id)sender
{
    [theMenu clear];
	[ClipItem resetCount];
    [theMenu refreshSearch];
    if (searchPanel)
        [searchPanel refresh];
}

- (IBAction)disableHotkeys:(id)sender {
    [hotkeys disable];
}

- (IBAction)enableHotkeys:(id)sender {
    [hotkeys enable];
}


- (IBAction)disable:(id)sender{
}

- (IBAction)enable:(id)sender
{
}

- (IBAction)pause:(id)sender{
}

- (IBAction)resume:(id)sender{
}

- (IBAction)save:(id)sender{
    int i=0;
    NSInteger count;
    id selectedItem = [theMenu getSelected];

    NSMutableArray *array = [theMenu clipArray];
    debug_printf ("Saving %lu items ...\n",[array count]);
    count = [array count];
    if (selectedItem) {
        for (i=0; i<count; i++) {
            if ([array objectAtIndex:i] == [selectedItem dict]) {
                debug_printf ("... selection %d...\n", i);
                [UD setObject:[NSNumber numberWithInt:i]
                    forKey:DefaultsSelection];
                break;
            }
        }
    } else {
        [UD setObject:[NSNumber numberWithInt:-1]
            forKey:DefaultsSelection];
    }

    [UD setObject:array 
        forKey:DefaultsClips];
    [UD setObject:[NSNumber numberWithBool:[theMenu frozen]]
        forKey:DefaultsFrozen];
    [UD setObject:[NSNumber numberWithInteger:[monitor changeCount]] 
        forKey:DefaultsChangeCount];

    if (iconNormal)
        [self saveObject:iconNormal forKey:DefaultsRedIcon];

    if (iconFrozen)
        [self saveObject:iconFrozen forKey:DefaultsBlueIcon];

    if (prefsPanel)
        [prefsPanel saveFrameUsingName:DefaultsFramePrefs];

    if (searchPanel)
        [searchPanel saveFrameUsingName:DefaultsFrameSearch];

    debug_printf ("Saving change count ... %ld\n", [monitor changeCount]);
}

- (IBAction)load:(id)sender {
    NSMutableArray *array = [UD objectForKey:DefaultsClips];
    id              loadedDict = nil;
    NSMutableDictionary *dict = nil;
    NSEnumerator *enm = nil;
    NSInteger selection = [UD integerForKey:DefaultsSelection];
    id selectedItem = nil;
    ClipItem *current = nil;
    NSInteger      frozen  = [UD integerForKey:DefaultsFrozen];
    int      iconEnabled = [UD boolForKey:DefaultsShowIcon];

    if (iconEnabled) {
        [theMenu enable];
    }

    if (frozen) {
        [theMenu lock];
    }

    if (array) {
        int i=0;
        debug_printf ("Loading ...\n");
        debug_printf ("... selection %ld...\n", selection);
        enm = [array objectEnumerator];
        
        while (loadedDict = [enm nextObject]) {
            debug_printf ("Making new copy: %s\n",
                          [[[loadedDict class] description] UTF8String]);
            dict = [NSMutableDictionary dictionaryWithCapacity:
                                            [loadedDict count]];
            [dict addEntriesFromDictionary:loadedDict];

            ClipItem *item = [[ClipItem alloc] initWithMonitor:monitor];

            /* This order is important */
            [item setDict:dict];            
            //            [monitor setItem:item];
            [item itemCreated];

            [self clipChanged:[item autorelease]];

            if (i == selection) {
                selectedItem = item;
            }
            i++;
        }
    }

    debug_printf ("Loading change count ... %ld\n", 
            [UD integerForKey:DefaultsChangeCount]);
    [monitor setChangeCount:[UD integerForKey:DefaultsChangeCount]];

    current = [monitor checkClipboardForChanges];

	hideNotification = TRUE;
    if (selectedItem)
        [self clipSelected:selectedItem];
	hideNotification = FALSE;

    if (current)
        [self clipChanged:current];
}

- (void)saveObject:(id)object forKey:(NSString *)keyName {
    NSMutableData *data;
    NSKeyedArchiver *archiver;
    
    data = [NSMutableData data];
    archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    // Customize archiver here
    [archiver encodeObject:object forKey:keyName];
    [archiver finishEncoding];
    [archiver release];

#if 0
    debug_printf ("%s key %s object %s size %d bytes\n", __FUNCTION__, 
            [keyName UTF8String],
            [[object description] UTF8String],
            [data length]);
#endif
    [UD setObject:data forKey:keyName];
}

- (id)loadObjectForKey:(NSString *)keyName {
    NSData *data;
    NSKeyedUnarchiver *unarchiver;
    id      obj = nil;

    //    debug_printf ("%s key %s\n", __FUNCTION__, [keyName UTF8String]);

    data = (NSData *)[UD objectForKey:keyName];
    if (data) {
        //        debug_printf("%s data is %s length %d bytes\n", __FUNCTION__, [[data description] UTF8String], [data length]);
        unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        // Customize unarchiver here
        obj = [unarchiver decodeObjectForKey:keyName];
        [unarchiver finishDecoding];
        [unarchiver release];

        //        debug_printf ("%s key %s object retainCount %d\n", __FUNCTION__, [keyName UTF8String], [obj retainCount]);
        //        debug_printf ("%s object is %s\n", __FUNCTION__, [[obj description] UTF8String]);
    } else {
        //        debug_printf ("%s data is %p\n", __FUNCTION__, data);
    }

    return obj;
}

-(IBAction)quit:(id)sender
{
    [NSApp terminate: self];
}

- (IBAction)setup:(id)sender
{
    debug_printf ("%s called\n", __FUNCTION__);
    if (!prefsPanel) {
        NSNib *nib = [[NSNib alloc] initWithNibNamed:@"Preferences.nib" bundle:nil];
        debug_printf ("Preferences nib @ %p\n", nib);
        
        NSArray *objects = NULL;
        
        if (nib) {
            [nib instantiateNibWithOwner: self topLevelObjects: &objects];		
            debug_printf ("objects @ %p count %lu\n", objects, [objects count]);
            
            NSObject *obj = [objects objectAtIndex:0];
            Class     class = [obj class];
            if ([class isSubclassOfClass: [PrefsPanel class]]) {
                debug_printf ("object @ %p is subclass of SearchPanel\n", obj);
                prefsPanel = (PrefsPanel *)obj;
            }
        }
    }

    
    [NSApp activateIgnoringOtherApps:YES];
    [prefsPanel refresh];
    [prefsPanel setLevel:NSModalPanelWindowLevel];
    [prefsPanel makeKeyAndOrderFront:self];
}

- (void)prefsChanged:(NSDictionary *)appDefaults {
    debug_printf ("%s called\n", __FUNCTION__);
    
    NSEnumerator *keys = [appDefaults keyEnumerator];
    id            key, value;

    while (key = [keys nextObject]) {
        value = [appDefaults objectForKey:key];

        /* Skip NSImage objects */
        if (![[value class] isSubclassOfClass: [NSImage class]])
            [UD setObject:value forKey:key];
    }

    [UD synchronize];

    /* Update the GUI as needed */

    /* Load new icons */
    NSImage *icon = nil;

    icon = [appDefaults objectForKey:DefaultsRedIcon];
    if (icon)
        [self setIconNormal:icon];

    icon = [appDefaults objectForKey:DefaultsBlueIcon];
    if (icon)
        [self setIconFrozen:icon];

    /* Update the menu bar */
    int      iconEnabled = [UD boolForKey:DefaultsShowIcon];

    if (iconEnabled) {
        [theMenu enable];
    } else {
        [theMenu disable];
    }
    [theMenu refreshMenuText];

    /* Check if we reduced the number of items */
    NSInteger max_clips = [UD integerForKey:DefaultsHistorySize];
    BOOL popped=NO;

	while ((max_clips > 0) && ([theMenu nUnlockedItems] >= max_clips)) {
		[theMenu popFirstClip];
        popped = YES;
	}

    /* We do it here instead of in the ClipMenu so that
     * we dont do it for each item popped
     */
    if (popped) 
        [theMenu refreshSearch];

    if (popped && searchPanel)
        [searchPanel refresh];

    /* Clear and re-register for hotkeys */
    [hotkeys clear];
    [self registerHotkeys];
}

- (IBAction)showCurrentClip:(id)sender {
	if (!notificationWindow) {
		[self showNotificationWindow:[[theMenu getSelected] text]
              forItem:(ClipItem *)[theMenu getSelected]
              forTime:[UD floatForKey:DefaultsFlashDelay]];
	} else {
		[self hideNotificationWindow];
	}
			
} 

- (void)about {	
	NSNib *nib = [[NSNib alloc] initWithNibNamed:@"About.nib" bundle:nil];
	debug_printf ("nib @ %p\n", nib);
	
	NSArray *objects = NULL;

	if (nib) {
		[nib instantiateNibWithOwner: self topLevelObjects: &objects];		
		debug_printf ("objects @ %p count %lu\n", objects, [objects count]);
		
		NSObject *obj = [objects objectAtIndex:0];
		Class     class = [obj class];
		if ([class isSubclassOfClass: [NSPanel class]]) {
			debug_printf ("object @ %p is subclass of NSAlert\n", obj);
				NSPanel *panel = (NSPanel *)obj;
				
                [panel setLevel:NSModalPanelWindowLevel];
                [panel makeKeyAndOrderFront:self];
		}
	}
}

- (IBAction)search:(id)sender {
    if (!searchPanel) {
        NSNib *nib = [[NSNib alloc] initWithNibNamed:@"Search.nib" bundle:nil];
        debug_printf ("nib @ %p\n", nib);
        
        NSArray *objects = NULL;
        
        if (nib) {
            [nib instantiateNibWithOwner: self topLevelObjects: &objects];		
            debug_printf ("objects @ %p count %lu\n", objects, [objects count]);
            
            NSObject *obj = [objects objectAtIndex:0];
            Class     class = [obj class];
            if ([class isSubclassOfClass: [SearchPanel class]]) {
                debug_printf ("object @ %p is subclass of SearchPanel\n", obj);
                searchPanel = (SearchPanel *)obj;
            }
        }
    }

    
    [NSApp activateIgnoringOtherApps:YES];
    [searchPanel refresh];
    [searchPanel setLevel:NSModalPanelWindowLevel];
    [searchPanel makeKeyAndOrderFront:self];
}

- (IBAction)support:(id)sender {
    [[NSWorkspace sharedWorkspace] 
        openURL:[NSURL URLWithString:URLSupport]];
}

- (IBAction)google:(id)sender {
    NSString *escaped_keywords = (NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                NULL, // Allocator
                                                (CFStringRef)[[[theMenu getSelected] 
                                                                    text] 
                                                                   string],
                                                NULL, // Chars to leave unescaped
                                                (CFStringRef)@"'+&", // Legal chars to be escaped
                                                kCFStringEncodingUTF8);
    // TEST STRING: abcd !@#$%^&*()-=_+{}[]\|;:'"<>,./?

    [escaped_keywords autorelease];

    NSString *google_url = [NSString 
                               stringWithFormat:URLGoogle,
                               [escaped_keywords UTF8String]];


    NSLog(@"%s",[google_url UTF8String]);

    [[NSWorkspace sharedWorkspace] 
        openURL:[NSURL URLWithString:google_url]];
}

- (IBAction)help:(id)sender {
    [[NSWorkspace sharedWorkspace] 
        openURL:[NSURL URLWithString:URLHelp]];
}

- (void)clipChanged:(ClipItem *)item {
    NSInteger max_clips = [UD integerForKey:DefaultsHistorySize];

	if ((max_clips > 0) && ([theMenu nItems] >= max_clips)) {
		[theMenu popFirstClip];
	}

    //    if ([item text]) {
    //        debug_printf ("clipChanged:\n%s\n----\n", [[item text] cString]);
    //    }
	hideNotification = TRUE;
    [theMenu addMenuItem:item];
	hideNotification = FALSE;
    if (searchPanel)
        [searchPanel refresh];
}

- (void)flashItem:(id)clipItem {
    [self showNotificationWindow:[clipItem text] forItem:clipItem 
			forTime:[UD floatForKey:DefaultsFlashDelay]];
}

- (void)clipSelected:(id)clipItem {
    [monitor setItem:clipItem];

    [theMenu setSelected:clipItem];
    if (searchPanel)
        [searchPanel refresh];
}

- (void)handleNextClip {
    //    debug_printf ("ClipController handleNextClip\n");
	[[theMenu nextClip] select:self];
}	

- (void)handlePrevClip {
#if 0
    NSRect rect;

    rect.origin = [NSEvent mouseLocation];
    //    rect.origin.y += 100;

    rect.size.width  = 25;
    rect.size.height = 100;

    NSWindow *menuWindow = [[NSWindow alloc] initWithContentRect: rect
                                           styleMask: ( NSBorderlessWindowMask )
                                           backing: NSBackingStoreBuffered defer: TRUE];
    if (!menuWindow) {
        /* ERROR */
        return;
    }

    //    [menuWindow setBackgroundColor: [NSColor clearColor]];
    //    [menuWindow setOpaque: NO];


    NSMenuView *menuView = [[[NSMenuView alloc] 
                                initWithFrame: rect] autorelease];
    [menuWindow setContentView: menuView];
    [menuView setMenu: theMenu];

    [menuWindow setFrame: rect display: NO];
    
    [NSApp activateIgnoringOtherApps:YES];
    [menuWindow setLevel: kCGUtilityWindowLevel ];
    [menuWindow makeKeyAndOrderFront:self];

    [NSApp runModalForWindow:menuWindow];
#endif

    //    debug_printf ("ClipController handlePrevClip\n");
    [[theMenu prevClip] select:self];
}	

- (void) hideNotificationWindow {
    if (notificationTimer) {
        [notificationTimer invalidate];
        notificationTimer = NULL;
    }

    if (notificationWindow) {
        [notificationWindow close];
        notificationWindow = NULL;
    }
}

- (void) showNotificationWindow:(NSAttributedString *)message 
						forItem:(ClipItem *)clipItem
                        forTime:(NSTimeInterval)howLong 
{
	if (hideNotification)
		return;
		
    if (notificationTimer) {
        [notificationTimer invalidate];
        notificationTimer = NULL;
    }

	if(!notificationWindow) {
		// Create a notification window.
		NSRect rect;
		rect.origin.x = rect.origin.y = 0; 
        rect.size.width  = [UD integerForKey:DefaultsFlashWidth];
        rect.size.height = [UD integerForKey:DefaultsFlashHeight];

		notificationWindow = [[NSWindow alloc] initWithContentRect: rect
			styleMask: ( NSBorderlessWindowMask )
			backing: NSBackingStoreBuffered defer: TRUE];
		[notificationWindow setLevel: 21];
		[notificationWindow setBackgroundColor: [NSColor clearColor]];
		[notificationWindow setOpaque: NO];
		[notificationWindow setIgnoresMouseEvents: YES];
		//[[ForeignWindow windowWithNSWindow: notificationWindow] makeSticky];
		
		NotificationView *notificationView = [[[NotificationView alloc] 
			initWithFrame: rect] autorelease];
		[notificationWindow setContentView: notificationView];
        [notificationWindow setIgnoresMouseEvents: YES];
		
        [notificationView setItem: clipItem];
	} else {
        [[notificationWindow contentView] setItem: clipItem];
	}

    NSRect frame = [notificationWindow frame];
    NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];

    frame.origin.x = [UD integerForKey:DefaultsFlashX];
    frame.origin.y = [UD integerForKey:DefaultsFlashY];

    if (frame.origin.x == ORIGIN_CENTER)
        frame.origin.x = (int)(0.5 * (screenFrame.size.width - frame.size.width));

    if (frame.origin.y == ORIGIN_CENTER)
        frame.origin.y = (int)(0.5 * (screenFrame.size.height - frame.size.height));

    [notificationWindow setFrame: frame display: NO];
    
    [notificationWindow setAlphaValue: 1.0];
    [notificationWindow setLevel: kCGUtilityWindowLevel ];
   		
	[notificationWindow orderFrontRegardless];

    notificationTimer = [NSTimer scheduledTimerWithTimeInterval:howLong
                                 target:self
                                 selector:@selector(hideNotificationWindow)
                                 userInfo:self
                                 repeats:FALSE];
                    
}

/* Returns the data source object for the clip history */
- (ClipMenu *)dataSource {
    return theMenu;
}


/* Delegate for SearchPanel */
- (BOOL)windowShouldClose:(id)sender {
    debug_printf("%s called for %s\n", __FUNCTION__, [[sender description] UTF8String]);
    //    searchPanel = nil;
    if (sender == prefsPanel) {
        [prefsPanel saveFrameUsingName:DefaultsFramePrefs];
        [prefsPanel endFlashGuide];
    }
    return YES;
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification {
    debug_printf("%s called for %s\n", __FUNCTION__, [[[aNotification object] description] UTF8String]);
}

/* Delegate for CCApplication */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    debug_printf("%s called\n", __FUNCTION__);
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender 
{
    debug_printf("%s called\n", __FUNCTION__);

    [self save:self];
    return NSTerminateNow;
}


@end

