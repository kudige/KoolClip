#import "AppleMenu.h"
#import "ClipController.h"

AppleMenu *globalMenu=NULL;
@implementation AppleMenu

+ (id)sharedInstance {
    if (!globalMenu) {
        globalMenu = [[AppleMenu alloc] init];
    }

    return globalMenu;
}

- (id)init {
	[super init];
	
    /* Obtain system status menu bar */
	selectedItem = NULL;
    theBar = [NSStatusBar systemStatusBar];
    itemCount = 0;
    theItem   = nil;
    ourIcon   = nil;
    ourText   = nil;

    /* Need to do an enable separately */
    return self;
}

- (void)refresh {
    if (theItem) {
        if (ourIcon) 
            [self setIcon:ourIcon];

        if (ourText)
            [self setText:ourText];
    }
}

- (void)enable {
    if (!theItem) {
        /* Add our status entry in this */
        theItem = [theBar statusItemWithLength:NSVariableStatusItemLength];
        [theItem retain];
        
        [theItem setHighlightMode:YES];
        [theItem setMenu:self];

        [self refresh];
    } else {
        debug_printf ("%s not doing anything since theItem is %p\n",
                      __FUNCTION__, theItem);
    }
}

- (void)disable {
    if (theItem) {
        [theBar removeStatusItem:theItem];
        [theItem autorelease];
        theItem = nil;
    } else {
        debug_printf ("%s not doing anything since theItem is %p\n",
                __FUNCTION__, theItem);
    }
}

- (void)setIcon:(NSImage *)icon {
    if (ourIcon) 
        [ourIcon autorelease];

    ourIcon = [icon retain];
    if (theItem)
        [theItem setImage: icon];
}

- (void)setText:(NSString *)text {
    NSInteger type = [UD integerForKey:DefaultsTextType];

    if (ourText)
        [ourText autorelease];

    ourText = [text retain];

    if (theItem && (type != TEXT_TYPE_NONE)) {
        [theItem setTitle: ourText];
    } else {
        [theItem setTitle:@""];
    }
}

- (void)countChanged {
	NSString *buf = @"";
    int count = itemCount - baseCount;
    int extended = [[NSUserDefaults standardUserDefaults] 
                       boolForKey:DefaultsShowExtendedText];
    int selection=0;

    if (selectedItem) {
        selection = [selectedItem getCount];
    }

    if (extended) {
        if (count > 1) {
            buf = [NSString stringWithFormat:@"(%d items)", count];
        } else if (count == 1) {
            buf = [NSString stringWithFormat:@"(%d item)", count];
        } else {
            buf = [NSString stringWithFormat:@"(empty)"];
        }
    } else {
        if (selection > 0) {
            buf = [NSString stringWithFormat:@"#%d", selection]; 
        }
    }

    [self setText:buf];
}


- (id)addMenuItem:(AppleMenuItem *)aitem {
    NSMenuItem *item = [super 
                                       insertItemWithTitle: [aitem title] 
                                       action: @selector(selectNoFlash:)
                                       keyEquivalent:@""
                                       atIndex: 0];
    //	[item setAttributedTitle:[[NSAttributedString alloc] initWithString:[aitem title]]];

    NSAttributedString *att_title = [aitem attributedTitle];
        
    if (att_title) {
        [item setAttributedTitle:att_title];
    }

    [item setTarget:[aitem retain]];
    [item setEnabled:TRUE];

    NSImage *tmp = [aitem icon];

    if (tmp) {
        [item setImage:tmp];
    }

    [aitem setMenuItem:item];
    [aitem setMenu:self];

    itemCount++;
    [self countChanged];

	return item;
}

- (id)myInsertItem:(id)item atIndex:(int)idx
{
	itemCount++;
	[super insertItem:item atIndex:idx];
	return item;
}

- (id)insertItemWithTitle:(NSString *)aString 
                   action:(SEL)aSelector 
            keyEquivalent:(NSString *)keyEquiv 
                  atIndex:(unsigned int)index 
               withTarget:(id)target
{
    NSMenuItem *mitem;
    itemCount++;
//    baseCount++;
    
    mitem = (NSMenuItem *)[super insertItemWithTitle:aString action:aSelector keyEquivalent:keyEquiv atIndex:index];
    [mitem setTarget:target];
    return mitem;
}

- (void)clear {
    int i=0;

    for (i=0; i<itemCount;i++) {
		id item = [self itemAtIndex:0];
        [self removeItem:item];
//		[item release];
    }

    itemCount = 0;
    selectedItem = NULL;
    [self countChanged];
}

- (IBAction)unselectall:(id)sender {
    int i=0;
	
    for (i=0; i<itemCount;i++) {
        [[self itemAtIndex:i] setState:NSOffState];
    }
}

- (void)select:(AppleMenuItem *)aitem {
    [[aitem menuItem] setState:NSOnState];
	selectedItem = aitem;
    [self countChanged];
}

- (AppleMenuItem *)getSelected {
	return selectedItem;
}

- (void)setSelected:(AppleMenuItem *)aitem {
    [self unselectall:self];
    [self select:aitem];
}


@end
