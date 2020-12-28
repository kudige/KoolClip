#include "KoolClip.h"
#import "ClipMonitor.h"

double TIMER_INTERVAL = 0.5; /* secs */
@implementation ClipMonitor

- (id)init {
    self = [super init];
    clipItem = NULL;
    listeners = [[NSMutableArray array] retain];

	clip = [NSPasteboard generalPasteboard];
    [clip types];
    changeCount = [clip changeCount] - 1;

	debug_printf ("ClipMonitor inited\n");

	return self;
}

- (void)awakeFromNib {
    debug_printf ("ClipMonitor awakeFromNib\n");
}

- (IBAction)pause:(id)sender {
    [timer invalidate];
}

- (IBAction)resume:(id)sender {
	timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
             target:self 
			 selector:@selector(checkClipboardForChangesWithTimer:) 
             userInfo:self
			 repeats:TRUE];
			 
}

- (NSInteger)changeCount {
    return changeCount;
}

- (void)setChangeCount:(NSInteger)count {
    changeCount = count;
}

-(ClipItem *)clipItem {
    return clipItem;
}

-(void)setItem:(ClipItem *)newItem {
    int i=0;
    NSMutableDictionary *dict = [newItem dict];
    NSArray             *types = [dict allKeys];

    [self pause:self];
    [clip declareTypes:types owner:self];
    for (i=0; i < [types count]; i++) {
        NSString *type = [types objectAtIndex:i];
        if ([type isEqualToString:ATTRIB_LOCKED]) {
            continue;
        }
            [clip setData: [dict objectForKey:type] forType:type];
    }
    changeCount = [clip changeCount];
    [self resume:self];
}

- (void)registerListener:(id)target {
    [listeners addObject:target];
}

- (void)notifyListeners:(ClipItem *)newItem {
    /* Notify all the listeners */
    int i=0;

    for (i=0; i<[listeners count]; i++) {
        [[listeners objectAtIndex:i] performSelector:@selector(clipChanged:) withObject:newItem];
    }
}

- (ClipItem *)checkClipboardForChanges
{
	NSData   *data;
    NSArray  *types;
	NSString *typestr = NULL;
	
	int       i = 0;
	NSInteger       newCount = [clip changeCount];

    ClipItem *item = nil;

    //    debug_printf ("%s: newCount %d changeCount %d\n", __FUNCTION__,
    //            newCount, changeCount);
    /* Check if clipboard has changed */
	types = [clip types];		

    if (!types || ![types count]) {
        goto Return;
    }

	if (newCount == changeCount) {
        goto Return;
	}
	changeCount = newCount;


    item  = [[[ClipItem alloc] initWithMonitor:self] autorelease];
    //    debug_printf ("ITEM %p retaincount %d\n", item, [item retainCount]);
    /*
     * For each clipboard type, store the data to
     * the dictionary
     */
	for (i=0; i<[types count]; i++) {
		typestr = [types objectAtIndex:i];        

            data = [clip dataForType:typestr];

        //        debug_printf ("Type %d %s\n", i, [typestr UTF8String]);
		if (data) {
            [item add:typestr withData:data];        
		}
	}
    [item itemCreated];

 Return:
    return item;
}

- (void)checkClipboardForChangesWithTimer:(NSTimer *)timer
{
    id item = nil;
	item = [self checkClipboardForChanges];
    if (item)
        [self notifyListeners:item];
}

@end
