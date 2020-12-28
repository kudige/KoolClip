/* HotkeyInfo */

#import <Cocoa/Cocoa.h>

#define __CARBONSOUND__
#include <Carbon/Carbon.h>

@interface HotkeyInfo : NSObject
{
	EventHotKeyRef handle;      
	EventHotKeyID  evtid;
	
	id			   target;
	SEL			   selector;
} 

@end
