#include "KoolClip.h"

#import "HotkeyController.h"
#import "HotkeyTarget.h"

@implementation HotkeyTarget

- (void)awakeFromNib {
    debug_printf ("%s tag %ld\n", __FUNCTION__, [self tag]);
    name = [[NSString alloc] initWithString:@"noname"];
    [self setTitle:@"No hotkey"];
}

- (void)dealloc {
    if (name)
        [name release];
    [super dealloc];
}

- (void)setIDName:(NSString *)newName {
    if (name)
        [name autorelease];
    name = [newName retain];
}

- (void)setKeyString:(NSString *)keyString withModifiers:(NSInteger)newModifiers {
    if (![keyString length] || (!newModifiers && [keyString isEqualToString:KeyUnset])) {
        [self setTitle:@""];
        [self disableModifiers];
    } else {
        [self setTitle:keyString];
        [self setModifiers:newModifiers];
    }
}

- (void)setModifiers:(NSInteger)newModifiers {
    modifiers = newModifiers;

    [ctl setEnabled:YES];
    [cmd setEnabled:YES];
    [opt setEnabled:YES];
    
    [ctl    setState:(modifiers&controlKey)?NSOnState:NSOffState];
    [cmd    setState:(modifiers&cmdKey)?NSOnState:NSOffState];
    [opt    setState:(modifiers&optionKey)?NSOnState:NSOffState];
}

- (NSInteger)modifiers {
    return modifiers;
}

- (void)disableModifiers {
    [ctl setEnabled:NO];
    [cmd setEnabled:NO];
    [opt setEnabled:NO];
}

- (NSString *)IDname {
    return name;
}

- (NSString *)textInfo {
    return [self title];
}

- (IBAction)modifiersChanged:(id)sender {
    modifiers = ((([ctl state] == NSOnState)?controlKey:0) |
                 (([cmd state] == NSOnState)?cmdKey:0)     |
                 (([opt state] == NSOnState)?optionKey:0));
}

@end
