#include "KoolClip.h"
#import "HotkeyController.h"

#define __CARBONSOUND__
#include <Carbon/Carbon.h>

#define KEYCODE(str, num) [self setKey:str ForCode:num]

// Needed since its omitted for x86
EventTargetRef GetApplicationEventTarget (
   void
);

HotkeyController *globalHotkey = NULL;

@implementation HotkeyController

+ (id)sharedInstance {
  if (!globalHotkey) {
    return [[HotkeyController alloc] init];
  } else {
    //		debug_printf ("HotkeyController sharedInstance: globalHotkey @ %p\n", globalHotkey);
    return globalHotkey;
  }
}

- (id)init {
  bindings  = [[NSMutableDictionary dictionary] retain];
  keyToCode = [[NSMutableDictionary dictionary] retain];
  codeToKey = [[NSMutableDictionary dictionary] retain];
  count = 0;
  disabled  = NO;

  if (!globalHotkey)
    globalHotkey = self;

  [self initHotKeys];
  debug_printf ("HotkeyController init: self @ %p\n", self);
  return self;
}

/*
 * Enable all currently defined hotkeys
 */
- (void)enable {
  NSEnumerator *handles = [bindings keyEnumerator];
  id            handleId=nil, infoId=nil;
  HotkeyInfo   *info = NULL;

  while (handleId = [handles nextObject]) {
    infoId = [bindings objectForKey:handleId];

    info = [infoId pointerValue];
    if (info) {
      [self enableHotkey:info firstTime:NO];
    }
  }

  disabled = NO;    
}

/*
 * Disable all currently defined hotkeys
 */
- (void)disable {
  NSEnumerator *handles = [bindings keyEnumerator];
  id            handleId=nil, infoId=nil;
  HotkeyInfo   *info = NULL;

  while (handleId = [handles nextObject]) {
    infoId = [bindings objectForKey:handleId];

    info = [infoId pointerValue];
    if (info) {
      [self disableHotkey:info];
    }
  }

  disabled = YES;
}

/*
 * Clear all hotkeys
 */
- (void)clear {
  NSEnumerator *handles = [bindings keyEnumerator];
  id            handleId=nil, infoId=nil;
  HotkeyInfo   *info = NULL;

  while (handleId = [handles nextObject]) {
    infoId = [bindings objectForKey:handleId];
        
    info = [infoId pointerValue];
    if (info) {
      [self disableHotkey:info];
      //            free(info);
    }
  }

  [bindings removeAllObjects];
  count = 0;
}

- (void)setKey:(NSString *)key ForCode:(int)code {
  [keyToCode setObject:[NSNumber numberWithInt:code] forKey:key];
  [codeToKey setObject:key forKey:[NSNumber numberWithInt:code]];
}

- (void)addHotkey:(NSString *)key withModifiers:(NSUInteger)modifiers target:(id)obj selector:(SEL)sel {
  /* No hotkey set */
  if ([key length] == 0) {
    return;
  }
    
  id keycodeNum = [keyToCode objectForKey:key];

  if (!keycodeNum) {
    debug_printf ("%s ERROR key %s not found\n", __FUNCTION__, [key UTF8String]);
    return;
  }

  int keycode = [keycodeNum intValue];
  HotkeyInfo   *info = (HotkeyInfo *)malloc(sizeof(*info));
  EventHotKeyID myid;
	
  if (!info) {
    debug_printf ("FATAL : Out of memory\n");
    /* Should throw something */
    return;
  }
	 
  memset(info, 0, sizeof(*info));
	
  info->target    = obj;
  info->selector  = sel;
  info->keycode     = keycode;
  info->modifiers = modifiers;

  myid.signature  = 0;
  myid.id = count++;
	
  info->myid      = myid;
  info->enabled   = FALSE;
  [self enableHotkey:info firstTime:YES];
}

- (void)enableHotkey:(HotkeyInfo *)info firstTime:(BOOL)firstflag{
  if (!info) {
    debug_printf ("%s ERROR info is NULL\n", __FUNCTION__);
    return;
  }

  if (info->enabled)
    return;

  int keycode         = info->keycode;
  NSInteger modifiers      = info->modifiers;
  EventHotKeyID myid = info->myid;

  void		 *handle = NULL;
  id            handleId;
  id            infoId;

  /* returns handle */
  RegisterEventHotKey(keycode, 
		      (int)modifiers, 
		      myid, 
		      GetApplicationEventTarget(), 0, 
		      &info->handle);

    debug_printf("%s handle %p\n", __FUNCTION__, info->handle);
  /* Associate handle with info */
  handle = (void *)info->handle;
  handle = (void *)((unsigned long)handle & 0xffffffff);
  handleId = [NSValue valueWithPointer:handle];
  infoId   = [NSValue valueWithPointer:info];
  if (firstflag) {
    [bindings   setValue:infoId
		forKey:handleId ];
  }

  info->enabled = YES;
}

- (void)disableHotkey:(HotkeyInfo *)info {
  if (!info) {
    debug_printf ("%s ERROR info is NULL\n", __FUNCTION__);
    return;
  }

  if (!info->enabled)
    return;

  UnregisterEventHotKey(info->handle);
  info->handle = 0;
  info->enabled = NO;
}

- (void)hotkeyEvent:(EventHotKeyRef)handle {
  if (disabled)
    return;

  handle = (void *)((long)handle & 0xffffffff);
  debug_printf("%s handle %p\n", __FUNCTION__, handle);
    
  id handleId = [NSValue valueWithPointer:(void *)handle];
  HotkeyInfo *info = (HotkeyInfo *)[[bindings objectForKey:handleId] pointerValue];
	
  if (info) {
    id  target = info->target;
    SEL sel    = info->selector;
		
    [target performSelector:sel];
  }
}



- (NSString *)stringForKey:(int)keycode withModifiers:(int)modifiers {
  NSString *str = [self stringForCode:keycode];
  if (!str) {
      str = @"<unknown>";
  }

  str = [str stringByAppendingString:[self stringForModifiers:modifiers]];

  return str;
}

- (NSString *)stringForModifiers:(int)modifiers {
    NSString *str = @"";

  if (modifiers & cmdKey) {
    str = [str stringByAppendingString:@"-cmd"];
  }

  if (modifiers & optionKey) {
    str = [str stringByAppendingString:@"-opt"];
  }

  if (modifiers & controlKey) {
    str = [str stringByAppendingString:@"-ctl"];
  }

  return str;
}

- (NSString *)stringForCode:(int)keycode {
  return [codeToKey objectForKey:[NSNumber numberWithInt:keycode]];
}

- (int)codeForString:(NSString *)string {
  NSNumber *num = [keyToCode objectForKey:string];
  if (num) {
    return [num intValue];
  } else {
    return -1;
  }
}

- (void)initHotKeys {
  KEYCODE(@"A", 0);
  KEYCODE(@"B", 11);
  KEYCODE(@"C", 8);
  KEYCODE(@"D", 2);
  KEYCODE(@"E", 14);
  KEYCODE(@"F", 3);
  KEYCODE(@"G", 5);
  KEYCODE(@"H", 4);
  KEYCODE(@"I", 34);
  KEYCODE(@"J", 38);
  KEYCODE(@"K", 40);
  KEYCODE(@"L", 37);
  KEYCODE(@"M", 46);
  KEYCODE(@"N", 45);
  KEYCODE(@"O", 31);
  KEYCODE(@"P", 35);
  KEYCODE(@"Q", 12);
  KEYCODE(@"R", 15);
  KEYCODE(@"S", 1);
  KEYCODE(@"T", 17);
  KEYCODE(@"U", 32);
  KEYCODE(@"V", 9);
  KEYCODE(@"W", 13);
  KEYCODE(@"X", 7);
  KEYCODE(@"Y", 16);
  KEYCODE(@"Z", 6);
  KEYCODE(@"0", 29);
  KEYCODE(@"1", 18);
  KEYCODE(@"2", 19);
  KEYCODE(@"3", 20);
  KEYCODE(@"4", 21);
  KEYCODE(@"5", 23);
  KEYCODE(@"6", 22);
  KEYCODE(@"7", 26);
  KEYCODE(@"8", 28);
  KEYCODE(@"9", 25);
  KEYCODE(@"[",  33);
  KEYCODE(@"]",  30);
  KEYCODE(@"\\",  42);
  KEYCODE(@";",  41);
  KEYCODE(@"'",  39);
  KEYCODE(@",",  43);
  KEYCODE(@".",  47);
  KEYCODE(@"/",  44);
  KEYCODE(@"-",  27);
  KEYCODE(@"=",  24);
  KEYCODE(@"`",  50);
  KEYCODE(@"TAB", 48);
  KEYCODE(@"DEL", 51);
  KEYCODE(@"ESC", 53);
  KEYCODE(@"up", 126);
  KEYCODE(@"down", 125);
  KEYCODE(@"left", 123);
  KEYCODE(@"right", 124);
  KEYCODE(@"F1", 122);
  KEYCODE(@"F2", 120);
  KEYCODE(@"F3", 99);
  KEYCODE(@"F4", 118);
  KEYCODE(@"F5", 96);
  KEYCODE(@"F6", 97);
  KEYCODE(@"F7", 98);
  KEYCODE(@"F8", 100);
  KEYCODE(@"F9", 101);
  KEYCODE(@"F10", 109);
  KEYCODE(@"F11", 103);
  KEYCODE(@"F12", 111);
}

@end
