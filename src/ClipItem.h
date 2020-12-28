/* ClipItem */

#import <Cocoa/Cocoa.h>

#define ClipTypeUnknown  0
#define ClipTypeText     1
#define ClipTypeImage    2
#define ClipTypeFile     3
#define ClipTypeURL      4
#define ClipTypeRTF      5

//#import "ClipMonitor.h"
#import "AppleMenuItem.h"

@interface ClipItem : AppleMenuItem
{
	int						 myCount;
    id                       monitor;
    int                      clipType;
    int                      locked;
    NSMutableDictionary     *dict;

    /* For Text */
    NSString                *mainTitle;
    NSAttributedString      *mainText;
    NSImage                 *mainIcon;
    NSString                *searchText;

    /* For Image */
    NSImage                 *mainImage;
    NSString                *imageInfo;
    float                    zoom; /* For Images */

    /* For URL previews */
    NSMutableData           *urlData;
    NSURLConnection         *urlConnection;
}

+ (void)resetCount;

/*
 * Constructor 
 */
- (id)initWithMonitor:(id)clipMon;

/*
 * Destructor
 */
- (void)dealloc;

/*
 * Once the tppe is determined, set it.
 */

- (void)setType:(int)type override:(BOOL)flag;

/*
 * Internal - create a ClipItem with segments from the clipboard data
 */
- (void)add:(NSString *)type withData:(NSData *)data;

/*
 * Creation from storage
 */
- (void)setDict:(NSMutableDictionary *)newdict;

/*
 * This will be called by the creator to indicate all the pasteboard
 * entries have been transferred.
 */
- (void)itemCreated;


- (NSMutableDictionary *)dict;

/*
 * Get the title to display in the menu
 */
- (NSString *)title;

/*
 * Get the image icon to display in the menu
 */
- (NSImage *)icon;

/*
 * Get the full text to display (in notification view)
 */
- (NSAttributedString *)text;

/*
 * Keywords to search for
 */
- (NSString *)keywords;

/*
 * Get the full image to display (in notification view)
 */
- (NSImage *)image;

/*
 * Get the info for the image to display (in notification view)
 */
- (NSString *)imageInfo;

/*
 * Get the item count - resets when the KoolClip is cleared.
 */
- (int)getCount;

- (NSNumber *)index;

// For checkbox in search panel
- (NSNumber *)locked;

// For checkbox in search panel
- (void)setLocked:(int)value;

// For checkbox in search panel
- (void)toggleLocked;

/*
 * Display the flash window for this item.
 */
- (void)flash;

/*
 * Select the current item and flash it
 */
- (void)select:(id)menuItem;

/*
 * Select the current item without flashing it
 */
- (void)selectNoFlash:(id)menuItem;

/*
 * Load the full image from the clipboard.
 */
- (void)loadImageFromClipboard;

/*
 * Load given image into the ClipItem
 */
- (void)loadImage:(NSImage *)image;

/*
 * Refresh the display of this item (in the menu).
 */
- (void)refresh;

/*
 * Image scaling
 */
- (NSImage *)fitImage:(NSImage *)image 
               toSize:(NSSize)size 
               zoomIs:(float *)pZoom;

/* Delegate for URL loading */
- (void)connection:(NSURLConnection *)connection 
  didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection 
  didReceiveData:  (NSData *)data;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error;

@end
