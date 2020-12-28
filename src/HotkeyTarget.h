/* HotkeyTarget */

#import <Cocoa/Cocoa.h>

@interface HotkeyTarget : NSButton
{
    NSString     *name;
    //    NSString *textInfo;

    IBOutlet  id  cmd;
    IBOutlet  id  ctl;
    IBOutlet  id  opt;

    NSInteger     modifiers;
}

- (IBAction)modifiersChanged:(id)sender;

- (void)setIDName:(NSString *)name;
- (void)setKeyString:(NSString *)keyString withModifiers:(NSInteger)modifiers;
- (void)setModifiers:(NSInteger)modifiers;
- (void)disableModifiers;
- (NSInteger)modifiers;

- (NSString *)IDname;

//- (void)setTextInfo:(NSString *)text;
- (NSString *)textInfo;

- (NSString *)textInfo;
@end
