#include "HotkeyController.h"
#import "ClipMenu.h"
#import "ClipController.h"

// Missing prototype n x86
SEL sel_getUid(const char *str); 

NSInteger convertModifiers(NSInteger carbon) {
    NSInteger cocoa = 0;

    if (carbon & controlKey)
        cocoa |= NSControlKeyMask;

    if (carbon & cmdKey)
        cocoa |= NSCommandKeyMask;

    if (carbon & optionKey)
        cocoa |= NSAlternateKeyMask;

    return cocoa;
}

@implementation ClipMenu

#define TEXT_IS_ON() ([[NSUserDefaults standardUserDefaults]               \
                   integerForKey:DefaultsTextType] == TEXT_TYPE_COUNT)

- (id)init {
    [super init];
    locked = NO;
    searchString = [[NSString alloc] initWithString:@""];
    searchArray = nil;
    return self;
}

- (void)lock
{
    debug_printf ("%s\n", __FUNCTION__);
    locked = !locked;
    [self refreshMenuText];
}

- (void)toggleText
{
    if (TEXT_IS_ON()) {
        [[NSUserDefaults standardUserDefaults] 
            setInteger:TEXT_TYPE_NONE
            forKey:DefaultsTextType];
    } else {
        [[NSUserDefaults standardUserDefaults] 
            setInteger:TEXT_TYPE_COUNT
            forKey:DefaultsTextType];
    }

    [self refreshMenuText];
    [self countChanged];
}

- (void) refreshMenuText {
	[prefs  setKeyEquivalent:[[UD stringForKey:DefaultsKeyPrefs] lowercaseString]];
	[prefs  setKeyEquivalentModifierMask:convertModifiers([UD integerForKey:DefaultsModPrefs])];    

	[search setKeyEquivalent:[[UD stringForKey:DefaultsKeySearch] lowercaseString]];
	[search setKeyEquivalentModifierMask:convertModifiers([UD integerForKey:DefaultsModSearch])];    

	[prev   setKeyEquivalent:[[UD stringForKey:DefaultsKeyPrev] lowercaseString]];
	[prev   setKeyEquivalentModifierMask:convertModifiers([UD integerForKey:DefaultsModPrev])];

	[next   setKeyEquivalent:[[UD stringForKey:DefaultsKeyNext] lowercaseString]];
	[next   setKeyEquivalentModifierMask:convertModifiers([UD integerForKey:DefaultsModNext])];
    
	[lock   setKeyEquivalent:[[UD stringForKey:DefaultsKeyLock] lowercaseString]];
	[lock   setKeyEquivalentModifierMask:convertModifiers([UD integerForKey:DefaultsModLock])];
	
	[clear  setKeyEquivalent:[[UD stringForKey:DefaultsKeyClear] lowercaseString]];
	[clear  setKeyEquivalentModifierMask:convertModifiers([UD integerForKey:DefaultsModClear])];
    
	[quit   setKeyEquivalent:[[UD stringForKey:DefaultsKeyQuit] lowercaseString]];
	[quit   setKeyEquivalentModifierMask:convertModifiers([UD integerForKey:DefaultsModQuit])];

    if (locked) {
        debug_printf ("%s: locked\n", __FUNCTION__);
        [lock setTitle:MenuTextUnfreeze];
        [self setIcon: BlueIcon];
    } else {
        debug_printf ("%s: unlocked\n", __FUNCTION__);
        [lock setTitle:MenuTextFreeze]; 
        [self setIcon: RedIcon];
    }

#ifdef WANT_TEXT_ON
    if (TEXT_IS_ON()) {
        [textOn setTitle:MenuTextHideText];
    } else {
        [textOn setTitle:MenuTextWantText];
    }
#endif

    [super refresh];
}


- (void)clear {
    int i;
	int count = itemCount - baseCount;

    for (i=0; i<count;i++) {
		id item = [self itemAtIndex:i];

        if ([item target]) {
            [[item target] release];
        }
    }

    [super clear];
    [self initMenuItems];
}

- (void)initMenuItems {
	int idx = itemCount;
	id  item;
	
	[self myInsertItem:[NSMenuItem separatorItem] atIndex: idx++];

    item =  [self insertItemWithTitle: MenuTextHelp
                  action : @selector(help:)
                  keyEquivalent : @""
                  atIndex : idx++
                  withTarget : CC];
    
    item = about = [self insertItemWithTitle: MenuTextAbout
                         action : @selector(about)
                         keyEquivalent : @""
                         atIndex : idx++
                         withTarget : CC];
    
    item = [self insertItemWithTitle: MenuTextSupport
                         action : @selector(support:)
                         keyEquivalent : @""
                         atIndex : idx++
                         withTarget : CC];
    
#ifdef WANT_TEXT_ON
    item = textOn = [self insertItemWithTitle: MenuTextWantText
                          action : @selector(toggleText)
                          keyEquivalent : @""
                          atIndex : idx++
                          withTarget : self];
#endif
    
    item =  prefs = [self insertItemWithTitle: MenuTextPrefs
                          action : @selector(setup:)
                          keyEquivalent : @""
                          atIndex : idx++
                          withTarget : CC];

    item =  search = [self insertItemWithTitle: MenuTextSearch
                           action : @selector(search:)
                           keyEquivalent : @""
                           atIndex : idx++
                           withTarget : CC];

	[self myInsertItem:[NSMenuItem separatorItem] atIndex: idx++];
    
    item = prev = [self insertItemWithTitle: MenuTextPrev
                        action : @selector(handlePrevClip)
                        keyEquivalent : @""
                        atIndex : idx++
                        withTarget :  CC];
    item = next = [self insertItemWithTitle: MenuTextNext 
                        action : @selector(handleNextClip)
                        keyEquivalent : @""
                        atIndex : idx++
                        withTarget :  CC];
	[self myInsertItem:[NSMenuItem separatorItem] atIndex: idx++];

    lock = item = [self insertItemWithTitle: MenuTextFreeze 
                 action : @selector(lock)
                 keyEquivalent : @""
                 atIndex : idx++
                 withTarget : self];

    item = clear = [self insertItemWithTitle: MenuTextClear 
                         action : @selector(clear:)
                         keyEquivalent : @""
                         atIndex : idx++
                         withTarget : CC];
    item = quit = [self insertItemWithTitle: MenuTextQuit 
                        action : @selector(quit:)
                        keyEquivalent : @""
                        atIndex : idx++
                        withTarget : CC];

    /* Refresh everything - TODO - one func */
    [self refreshMenuText];
    [self countChanged];

	baseCount = itemCount;
	debug_printf ("Basecount %d idx %d\n", baseCount, idx);
}

- (void)awakeFromNib {
    //[self setIcon:RedIcon];
    [self refreshMenuText];
    
	debug_printf ("ClipMenu awakeFromNib\n");
}

- (id)addMenuItem:(AppleMenuItem *)aitem {
	id item = [super addMenuItem:aitem];
	
	if (!locked) {
		[self setSelected:aitem];
	} else {
		[[self getSelected] select: self];
	}
	
    /* Search box - TODO - Move it to data */
    NSString *mainString = [[aitem text] string];
    NSRange range;

    if (searchString && [searchString length] > 0) {
        range = [mainString
                    rangeOfString:searchString
                    options:NSCaseInsensitiveSearch];
        if (range.length > 0) {
            [searchArray insertObject:aitem atIndex:0]; /* Code copy */
        }
    } else {
        [searchArray insertObject:aitem atIndex:0]; /* Code copy */
    }

	return item;
}	

- (int)nItems {
	return itemCount - baseCount;
}

- (int)nUnlockedItems {
    int unlockedCount = 0;
  
	int count = itemCount - baseCount;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    int i=0;
    id item;
    if (array) {
        for (i=count-1; i>=0; i--) {
            item = [self itemAtIndex:i];
            if (![[[item target] locked] intValue]) 
                unlockedCount ++;
        }
    } else {
        debug_printf ("ERROR: Cannot save clipboard to disk, out of memory\n");
    }

    return unlockedCount;
}

- (int)nLockedItems {
    int lockedCount = 0;

	int count = itemCount - baseCount;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    int i=0;
    id item;
    if (array) {
        for (i=count-1; i>=0; i--) {
            item = [self itemAtIndex:i];
            if ([[[item target] locked] intValue]) 
                lockedCount ++;
        }
    } else {
        debug_printf ("ERROR: Cannot save clipboard to disk, out of memory\n");
    }

    return lockedCount;
}

- (BOOL)frozen {
    return locked;
}

/*
 * Returns all the clips in an array, oldest one at index 0
 */
- (NSMutableArray *)clipArray {
	int count = itemCount - baseCount;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    int i=0;
    id item;
    if (array) {
        for (i=count-1; i>=0; i--) {
            item = [self itemAtIndex:i];
            [array addObject:[[item target] dict]];
        }
    } else {
        debug_printf ("ERROR: Cannot save clipboard to disk, out of memory\n");
    }

    return array;
}

/*
 * Remove the oldest clip 
 */
- (void)popFirstClip {
	int count = itemCount - baseCount;
    int toremove = count-1;

	id  item  = [self itemAtIndex:toremove];
	while (toremove >= 0 && 
           (([[[item target] locked] intValue]) ||
            (locked && [item target] == [self getSelected]) )) {
        toremove--;
        item  = [self itemAtIndex:toremove];
    }

    if (toremove >= 0) {
        if ([item target] == [self getSelected]) {
            selectedItem = NULL;
        }

        [[item target] release];
        
        [self removeItem:item];
        itemCount--;
    }
}

- (AppleMenuItem *)prevClip {
    int i=0;
	int found = -1;
	int count = itemCount - baseCount;
	id  foundid;
	
    for (i=0; i<count;i++) {
        if ([[self itemAtIndex:i] state] == NSOnState) {
			found = i;
			break;
		}
    }	
	
	if (found >= 0) {
/* Uncomment next line for cycling to the end */
//		prev = (count+found-1) % count;
		if (found > 0)
			found = found-1;
		
		foundid = [[self itemAtIndex:found] target];			
		return (AppleMenuItem *)foundid;
	}

	return nil;
}

- (AppleMenuItem *)nextClip {
    int i=0;
	int found = -1;
	int count = itemCount - baseCount;
	id  foundid;
	
    for (i=0; i<count;i++) {
        if ([[self itemAtIndex:i] state] == NSOnState) {
			found = i;
			break;
		}
    }	
	
	if (found > -1 && found < count) {
/* Uncomment next line for cycling back */
//		next = (found+1) % count;
		if (found < count-1)
			found = found+1;
			
		foundid = [[self itemAtIndex:found] target];			
		return (AppleMenuItem *)foundid;
	}
	
	return nil;
}
/* Search related data operations */
- (void)refreshSearch {
    int i=0;
    id  item;
	int count = itemCount - baseCount;

    if (searchArray) {
        [searchArray autorelease];
    }

    NSRange range;
    searchArray = [[NSMutableArray arrayWithCapacity:count] retain];
    
    if (searchArray) {
        for (i=0; i<count; i++) {
            NSString *mainString = nil;
            item = [[self itemAtIndex:i] target];
            mainString = (NSString *)[item keywords];

            if (!mainString) {
                mainString = [item title];
            }

            if (searchString && [searchString length] > 0) {
                range = [mainString
                            rangeOfString:searchString
                            options:NSCaseInsensitiveSearch];
                if (range.length > 0) {
                    [searchArray addObject:item]; /* Code copy */
                }
            } else {
                [searchArray addObject:item]; /* Code copy */
            }
        }
    } else {
        debug_printf ("ERROR: Cannot save clipboard to disk, out of memory\n");
    }
}

- (void)setSearchString:(NSString *)string {
    if (searchString) {
        [searchString autorelease];
    }
    searchString = [string retain];
    [self refreshSearch];
}

- (NSString *)searchString {
    return searchString;
}
                          

- (NSMutableArray *)searchArray {
    return searchArray;
}


/* Data source for the search view */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    //    debug_printf("%s called for table view %p: count %d items %d base %d\n", 
    //           __FUNCTION__, aTableView, [self nItems], itemCount, baseCount);

    /* For robustness */
    if (!searchArray)
        [self setSearchString:@""];

    return [searchArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    //    debug_printf("%s called for table view %p rowIndex %d\n", 
    //           __FUNCTION__, aTableView, rowIndex);

    //    debug_printf ("Identifier %s\n", [[aTableColumn identifier] UTF8String]);

    /* For robustness */
    if (!searchArray)
        [self setSearchString:@""];

    SEL selector = sel_getUid([[aTableColumn identifier] UTF8String]);
    if (selector) {
        return [[searchArray objectAtIndex:rowIndex] 
                   performSelector:selector];
    } else {
        debug_printf ("%s: Selector is nil\n", __FUNCTION__);
        return @"No Info";
    }
}

- (id)tableView:(NSTableView *)aTableView objectForRow:(NSInteger)rowIndex {
    /* For robustness */
    if (!searchArray)
        [self setSearchString:@""];

    return [searchArray objectAtIndex:rowIndex];
}

@end

