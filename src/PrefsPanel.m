#import "PrefsPanel.h"
#import "ClipController.h"
#import "FlashEditWindow.h"
#import "HotkeyController.h"

@implementation PrefsPanel

#define KB 1024
#define MB (KB*KB)

- (void)awakeFromNib {
    flashGuide = nil;
    hotwin     = nil;
    currHotkey = nil;
    dirty      = NO;
    [self setFrameUsingName:DefaultsFramePrefs];
}

/*
 * Called during init from refresh to make sure all controls are consistent.
 * Called when user changes controls from uiChanged to make sure
 * we update our state with changed information.
 */
- (void)refreshControls {
    /* Show In Menu Bar */
    [showInMenuBar setState:iconEnabled?NSOnState:NSOffState];

    /* Enable or disable the related controles */
    [iconNormal setEnabled:iconEnabled];
    [iconFrozen setEnabled:iconEnabled];
    [textInMenuBar setEnabled:iconEnabled];
    [defaultIcons  setEnabled:iconEnabled];

    if (iconEnabled) {
        /* Text Type */
        [textInMenuBar setState:(textType == TEXT_TYPE_COUNT)?NSOnState:NSOffState];

        /* Normal Icon */
        /* Frozen Icon */
    }

    [urlPreview  setState:boolUrlPreview ?NSOnState:NSOffState];
    [urlKeywords setState:boolUrlKeywords?NSOnState:NSOffState];
    
    NSInteger urlIntval=0, tag=0;

    if (urlMaxbytes > MB) {
        urlIntval = urlMaxbytes / MB;
        tag = 2;
    } else if (urlMaxbytes > KB) {
        urlIntval = urlMaxbytes / KB;
        tag = 1;
    } else {
        urlIntval = urlMaxbytes;
        tag = 0;
    } 

    [urlMaxdata setIntegerValue:urlIntval];
    [urlKBMB selectItemAtIndex:tag];

    /* Tell all the HotkeyTargets to reload the latest modifier checkboxes.
       User might have changed them.*/
    [keyPrev   modifiersChanged:self];
    [keyNext   modifiersChanged:self];
    [keyCurr   modifiersChanged:self];
    [keyLock   modifiersChanged:self];
    [keyPrefs  modifiersChanged:self];
    [keySearch modifiersChanged:self];
    [keyClear  modifiersChanged:self];
    [keyGoogle modifiersChanged:self];
    [keyQuit   modifiersChanged:self];

    [self updateFlashGuide];
}

- (void)setDirty:(BOOL)newDirty {
    dirty = newDirty;
    [unsavedChanges setHidden:(!dirty)];
    [cancelButton setTitle:dirty?StringCancel:StringClose];
    //    [applyButton setEnabled:dirty];
}


/*
 * Populate the controls from the user defaults.
 */
- (void)refresh {
    /* When the dialog is opened, if we are already at flash, we dont get a notification.
     * Simulate this event.
     */
    [self tabView:tabView didSelectTabViewItem:[tabView selectedTabViewItem]];
    
    /* TAB 1 - GENERAL */    
    [historySize setIntegerValue:[UD integerForKey:DefaultsHistorySize]];

    /* Menu Bar Icon */
    iconEnabled = [UD boolForKey:DefaultsShowIcon];
    textType = [UD integerForKey:DefaultsTextType];
    if (iconEnabled) {
        /* Text Type */
        /* Normal Icon */
        /* Frozen Icon */
    }


    /* TAB 2 - FLASH WINDOW */

    /* Flash Origin */
    flashOrigin.x = [UD integerForKey:DefaultsFlashX];
    flashOrigin.y = [UD integerForKey:DefaultsFlashY];

    /* Flash Width */
    [flashWidth setIntegerValue:[UD integerForKey:DefaultsFlashWidth]];

    /* Flash Height */
    [flashHeight setIntegerValue:[UD integerForKey:DefaultsFlashHeight]];

    /* Flash Alpha */
    [flashAlpha setFloatValue: (100.0 * (1.0 - [UD floatForKey:DefaultsFlashAlpha]))];

    /* Flash Color */
    NSColor *color = [NSColor 
                        colorWithCalibratedRed: [UD floatForKey:DefaultsFlashColorRed]
                        green: [UD floatForKey:DefaultsFlashColorGreen]
                            blue: [UD floatForKey:DefaultsFlashColorBlue]
                            alpha:1.0];
    [flashColor setColor:color];

    /* Flash Window Display Time */
    [flashDelay setFloatValue: [UD floatForKey:DefaultsFlashDelay]];

    /* TAB 3 - URL ACTIONS */
    boolUrlPreview  = [UD boolForKey:DefaultsUrlPreview];
    boolUrlKeywords = [UD boolForKey:DefaultsUrlKeywords];
    urlMaxbytes     = [UD integerForKey:DefaultsUrlMaxData];

    /* TAB 4 - HOTKEYS */
    [keyNext   setKeyString:[UD stringForKey:DefaultsKeyNext] 
               withModifiers:[UD integerForKey:DefaultsModNext]];
    [keyPrev   setKeyString:[UD stringForKey:DefaultsKeyPrev] 
               withModifiers:[UD integerForKey:DefaultsModPrev]];
    [keyCurr   setKeyString:[UD stringForKey:DefaultsKeyCurr] 
               withModifiers:[UD integerForKey:DefaultsModCurr]];
    [keyClear  setKeyString:[UD stringForKey:DefaultsKeyClear] 
               withModifiers:[UD integerForKey:DefaultsModClear]];
    [keyLock   setKeyString:[UD stringForKey:DefaultsKeyLock] 
               withModifiers:[UD integerForKey:DefaultsModLock]];
    [keyPrefs  setKeyString:[UD stringForKey:DefaultsKeyPrefs] 
               withModifiers:[UD integerForKey:DefaultsModPrefs]];
    [keySearch setKeyString:[UD stringForKey:DefaultsKeySearch] 
               withModifiers:[UD integerForKey:DefaultsModSearch]];
    [keyClear  setKeyString:[UD stringForKey:DefaultsKeyClear] 
               withModifiers:[UD integerForKey:DefaultsModClear]];
    [keyGoogle setKeyString:[UD stringForKey:DefaultsKeyGoogle] 
               withModifiers:[UD integerForKey:DefaultsModGoogle]];
    [keyQuit   setKeyString:[UD stringForKey:DefaultsKeyQuit] 
               withModifiers:[UD integerForKey:DefaultsModQuit]];

    
    [self refreshControls];

    [self setDirty:NO];
}

/*
 * Return the current preferences as a dictionary.
 */
- (NSDictionary *)preferences {
    NSColor *color = [flashColor color];

    NSDictionary *appDefaults = 
        [[NSDictionary alloc] 
            initWithObjectsAndKeys:
                iconEnabled?@"yes":@"no",  DefaultsShowIcon,

            [NSNumber numberWithInteger:textType],
            DefaultsTextType,
            
            [NSNumber numberWithInt:[historySize intValue]],
            DefaultsHistorySize,

            [iconNormal image],
            DefaultsRedIcon,

            [iconFrozen image],
            DefaultsBlueIcon,

            /* Flash */
            [NSNumber numberWithInt:flashOrigin.x],
            DefaultsFlashX,

            [NSNumber numberWithInt:flashOrigin.y],
            DefaultsFlashY,
            
            [NSNumber numberWithInt:[flashWidth intValue]],
            DefaultsFlashWidth,

            [NSNumber numberWithInt:[flashHeight intValue]],
            DefaultsFlashHeight,

            [NSNumber numberWithFloat:(1.0 - ([flashAlpha floatValue]/100.0))],
            DefaultsFlashAlpha,

            [NSNumber numberWithFloat:[flashDelay floatValue]],
            DefaultsFlashDelay,

            [NSNumber numberWithFloat:[color redComponent]],
            DefaultsFlashColorRed,

            [NSNumber numberWithFloat:[color blueComponent]],
            DefaultsFlashColorBlue,

            [NSNumber numberWithFloat:[color greenComponent]],
            DefaultsFlashColorGreen,

            /* URL related */
            boolUrlPreview?@"yes":@"no",
            DefaultsUrlPreview,

            boolUrlKeywords?@"yes":@"no",
            DefaultsUrlKeywords,

            [NSNumber numberWithInteger:urlMaxbytes],
            DefaultsUrlMaxData,

            /* HOTKEYS */
            [keyPrev title],
            DefaultsKeyPrev,

            [keyNext title],
            DefaultsKeyNext,

            [keyCurr title],
            DefaultsKeyCurr,

            [keyLock title],
            DefaultsKeyLock,

            [keyPrefs title],
            DefaultsKeyPrefs,

            [keySearch title],
            DefaultsKeySearch,

            [keyClear title],
            DefaultsKeyClear,

            [keyGoogle title],
            DefaultsKeyGoogle,

            [keyQuit title],
            DefaultsKeyQuit,

           [NSNumber numberWithInteger: [keyPrev modifiers]],
            DefaultsModPrev,

            [NSNumber numberWithInteger: [keyNext modifiers]],
            DefaultsModNext,

            [NSNumber numberWithInteger: [keyCurr modifiers]],
            DefaultsModCurr,

            [NSNumber numberWithInteger: [keyLock modifiers]],
            DefaultsModLock,

            [NSNumber numberWithInteger: [keyPrefs modifiers]],
            DefaultsModPrefs,

            [NSNumber numberWithInteger: [keySearch modifiers]],
            DefaultsModSearch,

            [NSNumber numberWithInteger: [keyClear modifiers]],
            DefaultsModClear,

            [NSNumber numberWithInteger: [keyGoogle modifiers]],
            DefaultsModGoogle,

            [NSNumber numberWithInteger: [keyQuit modifiers]],
            DefaultsModQuit,
            
            nil];

    return appDefaults;
}


/*
 * UI Actions
 */
- (IBAction) uiChanged:(id)sender {
    debug_printf ("%s called by %s\n", __FUNCTION__, [[sender description] UTF8String]);

    iconEnabled     = [showInMenuBar state] == NSOnState;
    textType        = ([textInMenuBar state] == NSOnState)?TEXT_TYPE_COUNT:TEXT_TYPE_NONE;
    boolUrlPreview  = [urlPreview  state] == NSOnState;
    boolUrlKeywords = [urlKeywords state] == NSOnState;
    
    NSInteger tag         = [urlKBMB     indexOfSelectedItem];
    NSInteger intval      = [urlMaxdata  intValue];

    if (tag < 0 || tag>2)
        tag = 0;

    switch (tag) {
    case 0:
        urlMaxbytes = intval;
        break;

    case 1:
        urlMaxbytes = intval * KB;
        break;

    case 2:
        urlMaxbytes = intval * MB;
        break;
    }

    [self refreshControls];
    
    [self setDirty:YES];
}

- (IBAction) apply:(id)sender {
    debug_printf ("%s called by %s\n", __FUNCTION__, 
            [[sender description] UTF8String]);
    //    [self endFlashGuide];
    [CC prefsChanged:[self preferences]];
    [self setDirty:NO];
}

- (IBAction) cancel:(id)sender {
    debug_printf ("%s called by %s\n", __FUNCTION__, 
                  [[sender description] UTF8String]);

    if (dirty) {
        NSAlert *alert = [NSAlert alertWithMessageText: StringSaveMessage
                                  defaultButton:@"Save"
                                  alternateButton:@"Cancel"
                                  otherButton:@"Don't Save"
                                  informativeTextWithFormat: StringSaveInformative
                                      ];
        
        NSInteger choice = [alert runModal];

        switch (choice) {
        case NSAlertDefaultReturn: /* Save */
            [self apply:sender];
            break;

        case NSAlertAlternateReturn: /* Cancel */
            return; /* Dont fall through */

        case NSAlertOtherReturn: /* Don't Save */
            /* Dont do anything, just close it */
            printf("%s: discarding changes\n", __FUNCTION__);
            break;

        default:
            printf ("Ignoring Choice %ld\n", choice);
            break;
        }
    }

    [self endFlashGuide];
	[NSApp stopModal];
    [self performClose:sender];
}

- (IBAction) resetIcons:(id)sender {
    debug_printf ("%s called by %s\n", __FUNCTION__, 
            [[sender description] UTF8String]);

    /* Reset icons to factory defaults */
    [CC setIconNormal:nil];
    [CC setIconFrozen:nil];

    [iconNormal setImage:[CC unlockedIcon]];
    [iconFrozen setImage:[CC lockedIcon]];

    [self uiChanged:sender];
}

- (IBAction) support:(id)sender {
    [self performClose:sender];
    [CC support:sender];
}

- (void)startFlashGuide {
    if (!flashGuide) {
        debug_printf ("Enter flash\n");

        NSRect frame;
        NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
        
        frame.origin = flashOrigin;
        frame.size.width  = [UD integerForKey:DefaultsFlashWidth];
        frame.size.height = [UD integerForKey:DefaultsFlashHeight];
        
        if (frame.origin.x == ORIGIN_CENTER)
            frame.origin.x = (int)(0.5 * (screenFrame.size.width - frame.size.width));
        
        if (frame.origin.y == ORIGIN_CENTER)
            frame.origin.y = (int)(0.5 * (screenFrame.size.height - frame.size.height));
        
        flashGuide = [[FlashEditWindow alloc] 
                         initWithFrame:frame
                         target:self];
        
        [self updateFlashGuide];
    }
}

- (void)endFlashGuide {
    if (flashGuide) {
        [flashGuide release];
        flashGuide = nil;
    }
}

/*
 * Update the flash guide UI from the preferences changes
 */
- (void)updateFlashGuide {
    if (!flashGuide)
        return;

    NSColor *oldcolor = [flashGuide backgroundColor], *color = [flashColor color];
    debug_printf ("OldColor %s\nColor: %s\n", [[oldcolor description] UTF8String], [[color description] UTF8String]);

    [flashGuide setBackgroundColor: [flashColor color]];
    [flashGuide setAlphaValue: (1.0-([flashAlpha floatValue]/100.0))];
    [flashGuide display];
    NSRect frame = [flashGuide frame];
    frame.size.width  = [flashWidth  intValue];
    frame.size.height = [flashHeight intValue];
    [flashGuide setFrame:frame display:YES];
}

/* Flash Guide Delegate */

/*
 * Update the preferences from the flash guide change
 */
- (void)flashUpdated:(id)sender {
    NSRect frame = [sender frame];
    NSRect cont = frame; //[sender contentRectForFrameRect:frame];

    flashOrigin = frame.origin;

    [flashWidth  setIntValue:cont.size.width];
    [flashHeight setIntValue:cont.size.height];
}

- (void)windowDidMove:(NSNotification *)aNotification {
    if ([aNotification object] == flashGuide) {
        debug_printf ("%s called\n", __FUNCTION__);
        [self flashUpdated:[aNotification object]];
        [self uiChanged:[aNotification object]];
    }
}

- (void)windowDidResize:(NSNotification *)aNotification {
    if ([aNotification object] == flashGuide) {
        debug_printf ("%s called\n", __FUNCTION__);
        [self flashUpdated:[aNotification object]];
        [self uiChanged:[aNotification object]];
    }
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    NSString *ident = (NSString *)[tabViewItem identifier];
    debug_printf ("%s called item %s\n", __FUNCTION__, [ident UTF8String]);

    if ([ident isEqualToString:@"flash"]) {
        [self startFlashGuide];
    } else {
        [self endFlashGuide];
    }
}

/*
 * HOTKEY input related
 */
- (IBAction) hotPress:(id)sender {
    //    NSString *keyName=nil, *modName=nil;
    debug_printf ("%s sender %s\n", __FUNCTION__, [[sender IDname] UTF8String]);
    
    currHotkey = sender;

    if (!hotwin) {
        /*
        keyName = [[NSString stringWithString:@"Key"]
                              stringByAppendingString:[sender IDname]];


        modName = [[NSString stringWithString:@"Mod"]
                              stringByAppendingString:[sender IDname]];

        debug_printf ("keyName %s modName %s\n",
                [keyName UTF8String],
                [modName UTF8String]);
        */

        hotwin = [[HotkeyInputWindow alloc] 
                     initWithTarget:self];
    }

    /* Disable hotkeys before displaying the hotkey input window */
    [CC disableHotkeys:self];
    [hotwin setLevel: 21];
    [hotwin setOpaque: YES];
}

/*
 * HOTKEY input target
 */

- (void) hotkeyPressed:(NSNumber *)keycode withModifiers:(NSNumber *)modifiers {
    [currHotkey setKeyString:[[CC hotkeys] stringForCode:[keycode intValue]]
                withModifiers:[modifiers intValue]];

    debug_printf("%s closing hotwin\n", __FUNCTION__);
    [hotwin close];
    [self setDirty:YES];
}

/*
 * HOTKEY window delegate
 */
- (void)windowWillClose:(NSNotification *)aNotification {
    debug_printf ("%s called for %s\n", __FUNCTION__, [[[aNotification object] description] UTF8String]);
    
    if ([ aNotification object] == hotwin) {
        hotwin = nil;
        [CC enableHotkeys:self];
    }
}

@end
