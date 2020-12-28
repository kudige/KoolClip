#import "ClipItem.h"
#import "ClipMonitor.h"
#import "ClipController.h"

NSString *clipText(NSString *string) {
    NSString *mainTitle = nil;

    NSUInteger cliplen = [string length];
    
    if (cliplen > CLIP_LENGTH)
        cliplen = CLIP_LENGTH;
    
    if (cliplen < CLIP_LENGTH) {
        mainTitle =  [[NSString  alloc] 
                         initWithString:string];
    } else {
        mainTitle = [[[NSString 
                          stringWithString:[string substringToIndex:cliplen]]
                         stringByAppendingString:@"..."] retain];
    }

    return mainTitle;
}

@implementation ClipItem

static int count=0;

- (id)initWithMonitor:(id)clipMon {
    monitor = clipMon;

    dict = [[NSMutableDictionary dictionaryWithCapacity:100] retain];

    [self setLocked:0];
    mainText  = NULL;
    mainTitle = NULL;
    mainImage = NULL;
	imageInfo = NULL;
	myCount   = ++count;
    zoom      = 0;
    urlData   = nil;
    searchText= nil;
    urlConnection= nil;
    clipType  = ClipTypeUnknown;

    //    debug_printf ("ClipItem @ %p dict @ %p\n", self, dict);
	return self;
}

- (void)dealloc {
    //    debug_printf ("Deallocating clipItem %p\n", self);
    if (mainText)
        [mainText release];

    if (mainTitle)
        [mainTitle release];

    if (mainImage)
        [mainImage release];

    if (imageInfo)
        [imageInfo release];

    if (dict) {
        [dict removeAllObjects];
        [dict release];
    }

    if (urlConnection)
        [urlConnection release];


    //    if (urlData) 
    //        [urlData release];
    if (searchText)
        [searchText release];

    [super dealloc];
}

- (void)setType:(int)newtype override:(BOOL)force {
    if (clipType == ClipTypeUnknown || force) {
        clipType = newtype;
    }
}

/*
 * Get Attributes
 */

- (NSString *)title {
    return mainTitle;
}

- (NSAttributedString *)attributedTitle {
    NSMutableAttributedString *att_title =
        [[NSMutableAttributedString alloc]
            initWithString:[self title]];
    
    if ([[self locked] intValue]) {
        NSRange att_range = NSMakeRange(0, [att_title length]);
        [att_title addAttribute:NSForegroundColorAttributeName
                   value:[NSColor blueColor]
                   range:att_range];

    }
    
    return att_title;
}

- (NSAttributedString *)text {
    return mainText;
}

- (void)refresh {
    if (menuItem) {
        [menuItem setAttributedTitle:[self attributedTitle]];
    }
}

/*
 * Keywords to search for
 */
- (NSString *)keywords {
    return searchText;
}

/*
 * Get the image icon to display in the menu
 */
- (NSImage *)icon {
    return mainIcon;
}

/*
 * Get the full image to display (in notification view)
 */
- (NSImage *)image {
    return mainImage;
}

- (NSString *)imageInfo {
    return imageInfo;
}


- (int)getCount {
	return myCount;
}

- (NSNumber *)index {
    return [NSNumber numberWithInt:myCount];
}

// For checkboxes in search panel
- (NSNumber *)locked {
    return [NSNumber numberWithInt:locked];
}

- (void)setLocked:(int)value {
	locked = value;
    [dict setValue:[NSNumber numberWithInt:value] forKey:ATTRIB_LOCKED];
    [self refresh];
}

- (void)toggleLocked {
    [self setLocked: (locked)?0:1];
}

/*
 * ClipItem creation
 */
+ (void)resetCount {
	count = 0;
}

- (NSMutableDictionary *)dict {
    return dict;
}

- (void)setDict:(NSMutableDictionary *)newdict {
    if (dict) {
        [dict removeAllObjects];
        [dict autorelease];
    }

    dict = [newdict retain];
    if ([dict objectForKey:ATTRIB_LOCKED]) {
        [self setLocked:[[dict objectForKey:ATTRIB_LOCKED] intValue]];
    }
}

- (void)add:(NSString *)type1 withData:(NSData *)data1 {
    NSString *type = [NSString stringWithString:type1];
    NSData   *data = [NSData  dataWithData:data1];

    [dict setValue:data forKey:type];
}

- (void)itemCreated {
    int fontSize = 12;
    NSDictionary *attr = [NSDictionary 
                             dictionaryWithObjectsAndKeys:
                                 [NSColor blackColor], 
                             NSForegroundColorAttributeName,
                             [NSFont boldSystemFontOfSize: fontSize], 
                             NSFontAttributeName,
                             nil];
    

    NSData *data = nil;
    BOOL    filename = NO;

    /* Load from RTF pasteboard */
    data = [dict objectForKey:@"NeXT Rich Text Format v1.0 pasteboard type"];
    if (data){
        //        debug_printf (">>> Found Rich Text : \n");
        if (mainText)
            [mainText autorelease];

        mainText = [[NSAttributedString alloc] 
                       initWithRTF:data
                       documentAttributes:NULL];
    
        mainTitle = clipText([mainText string]);
        [self setType:ClipTypeRTF override:NO];

        goto Return;
    }


    /* Load filenames from the pasteboard */
    filename = ([dict objectForKey:@"NSFilenamesPboardType"] != NULL);

    /* Load from PICT pasteboard */
    data = [dict objectForKey:@"Apple PICT pasteboard type"];
    
    if (data) {
        //        debug_printf (">>> Found Image : \n");
        if (filename) {
            NSImage *image = [[NSImage alloc] initWithData:data];
            mainImage = image;
            mainIcon  = [image retain];
            [self setType :ClipTypeFile override:YES];
        } else {
            [self loadImage:[[[NSImage alloc] initWithData:data] autorelease]];
            [self setType :ClipTypeImage override:NO];

            goto Return;
        }
    } 

    /* Load from normal text pasteboard */
    data = (NSData *)[dict objectForKey:@"NSStringPboardType"];

    if (data) {
        NSUInteger len = [data length];

        if (len > 0) {
            //            debug_printf (">>> Found Normal Text : \n");
            NSString *string = [[[NSString alloc]
                                   initWithData:data
                                   encoding:NSUTF8StringEncoding] autorelease];
            if (!string) {
                debug_printf ("String is NULL: %s!!\n", 
                              (const char *)[data bytes]);
                goto Return;
            }
            
            if (!mainText) {
                mainText = [[NSAttributedString alloc] 
                               initWithString:string 
                               attributes:attr];
            }

            if (!mainTitle) {
                mainTitle = clipText(string);
            }
            if (!searchText) {
                searchText = [string retain];
            }

            /* URL handling */
            if (shouldUrlPreview || shouldUrlKeywords) {
                NSRange range = [string rangeOfString:@"://"];
                if (range.length > 0) {
                    NSURL *url = [NSURL URLWithString:string];
                    //                    debug_printf ("url @ %p for string %s\n",
                    //                            url, [string UTF8String]);
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];

                    urlData = [[NSMutableData data] retain];
                    
                    debug_printf ("%s connection %p urlData %p\n",
                            __FUNCTION__, urlConnection, urlData);
                    if ([NSURLConnection canHandleRequest:request]) {
                        /* Need to retain self, otherwise if we are freed while the connection is
                           not yet finished, we will be in a soup */
                        [self retain];
                        urlConnection = [[NSURLConnection connectionWithRequest:request
                                                delegate:self] retain];
                        debug_printf ("Connection %p started for %s\n",
                                urlConnection, [string UTF8String]);
                    }
                }
            }
            
        }

        [self setType:ClipTypeText override:NO];
        goto Return;
    }

 Return:
    if (filename) {
        imageInfo = [[mainText string] retain];
    }
    if (!mainTitle) {
        mainTitle = [[NSString alloc] initWithString:@"(Image)"];
    }
    if (!searchText) {
        searchText = [mainTitle retain];
    }
    return;
}

- (void)print {
    NSArray *types;
    //int i=0;
    NSUInteger cnt=0;

    debug_printf ("ClipItem @ %p dict @ %p\n", self, dict);

    cnt = [dict count];
    debug_printf ("dict count @ %lu\n", cnt);
    types  = [dict allKeys];

    /*
    for (i=0; i<[types count]; i++) {
        debug_printf ("type%d: %@\n", i, (NSString *)[types objectAtIndex:i]);
    }
     */
}

- (void)flash {
    [CC flashItem:self];
}

- (void)select:(id)menuItem {
    [CC clipSelected:self];
    [CC flashItem:self];
}

- (void)selectNoFlash:(id)menuItem {
    [CC clipSelected:self];
}

- (void)loadImageFromClipboard {
    NSImage *image = [[NSImage alloc] initWithPasteboard: 
                                          [NSPasteboard generalPasteboard]];
    if (image)
        [self loadImage:[image autorelease]];
}

- (void)loadImage:(NSImage *)image {
    NSSize iconSize  = {MENU_ICON_WIDTH,   MENU_ICON_HEIGHT};
    NSSize imageSmallSize = {FLASH_SMALL_WIDTH, FLASH_SMALL_HEIGHT};
    NSSize imageLargeSize = {FLASH_LARGE_WIDTH, FLASH_LARGE_HEIGHT};
    NSSize size;

    if (image) {
        size = [image size];
        if (!mainText)
            mainText = [[NSAttributedString alloc] initWithString:@"My Image"];
        mainIcon  = [[self fitImage:image toSize:iconSize zoomIs:nil] retain];

        if (size.width > imageLargeSize.width ||
            size.height > imageLargeSize.height) {
            mainImage = [[self fitImage:image 
                               toSize:imageLargeSize 
                               zoomIs:&zoom] retain];
        }

        if (size.width < imageSmallSize.width &&
            size.height < imageSmallSize.height) {
            mainImage = [[self fitImage:image 
                               toSize:imageSmallSize
                               zoomIs:&zoom] retain];
        }

        if (!mainImage) {
            zoom = 1;
            mainImage = [image retain];
        }

        /* This is displayed in the menu */
        /*        mainTitle = [[NSString alloc]
                        initWithFormat:@"%d Image %d x %d",
                        myCount,
                        (int)size.width, (int)size.height
                     ];
        */
        if (!mainTitle) {
            mainTitle = [[NSString alloc]
                            initWithFormat:@"Image %d x %d",
                            (int)size.width, (int)size.height
                         ];
        }
        
        /* This is displayed under the image in the flash window */
        imageInfo = [[NSString alloc]
                        initWithFormat:@"Image Size %d x %d @ Zoom %d %%",
                        (int)size.width, (int)size.height, (int)(zoom*100)
                     ];
    }
}

- (NSImage *)fitImage:(NSImage *)image 
               toSize:(NSSize)size 
             zoomIs:(float *)pZoom 
{
    NSSize tmps = [image size];
    
    float xfactor = size.width/tmps.width;
    float yfactor = size.height/tmps.height;
    float factor = (xfactor > yfactor)?yfactor:xfactor;
    
    //    debug_printf ("Actual Image: %0.02f, %0.02f factor %0.02f\n", 
    //            tmps.width, tmps.height, factor);
    
    if (factor > 0) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleBy:factor];
        
        NSSize new_size = [transform transformSize: [image size]];
        //            NSPoint new_point = NSZeroPoint;
        
        if (new_size.width < size.width) 
            new_size.width = size.width;
        
        NSImage * canvas = [[NSImage alloc] initWithSize: new_size];
        [canvas lockFocus];
        
        [transform concat];
        
        NSArray *reps = [image representations];
        if (reps.count > 0) {
            NSImageRep * rep = [reps objectAtIndex:0];
            [rep drawAtPoint: NSZeroPoint];
        }
        
        [canvas unlockFocus];

        if (pZoom)
            *pZoom = factor;
        return [canvas autorelease];
    }

    if (pZoom)
        *pZoom = 1;

    return image;
}

- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSURLResponse *)response 
{
    debug_printf ("%s for connection %p url %s mime %s\n", __FUNCTION__, 
                  connection, [[[response URL] absoluteString] UTF8String],
                  [[response MIMEType] UTF8String]);

    if ((NSOrderedSame != [[response MIMEType] caseInsensitiveCompare:@"text/html"]) &&
        (NSOrderedSame != [[response MIMEType] caseInsensitiveCompare:@"text/plain"])) {
        printf ("%s cancelling connection %p urlData @ %p mime %s\n", 
                __FUNCTION__, connection, urlData,
                [[response MIMEType] UTF8String]);

        [connection cancel];
        [self autorelease];
    } else {
        [urlData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:  (NSData *)data 
{
    //    NSMutableData *myUrlData = urlData;

    debug_printf ("%s for connection %p delta %lu\n", __FUNCTION__, connection,
            [data length]); 
    [urlData appendData:data];

    if ([urlData length] > [UD integerForKey:DefaultsUrlMaxData]) {
        debug_printf ("%s cancelling connection %p urlData @ %p\n", 
                __FUNCTION__, connection, urlData);

        [connection cancel];
        [self autorelease];
        //        [urlData autorelease];
        //        urlData = nil;
    }

    if (shouldUrlPreview) {
        NSAttributedString *htmlpage = nil;
        htmlpage = [[[NSAttributedString alloc] 
                        initWithHTML:urlData
                        documentAttributes:nil] 
                       autorelease];
        debug_printf ("htmlpage @ %p\n", htmlpage);
        
        if (htmlpage) {
            if (!imageInfo) {
                imageInfo = [[mainText string] retain];
            }

            if (mainText) {
                [mainText autorelease];
            }
            mainText = [htmlpage retain];
        }
    }

    if (shouldUrlKeywords) {
        if (searchText) {
            [searchText autorelease];
        }
        
        searchText = [[NSString alloc]
                         initWithData:urlData
                         encoding:NSUTF8StringEncoding];
        /* TODO - append the URL to this */
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSAttributedString *htmlpage = nil;
    htmlpage = [[[NSAttributedString alloc] 
                    initWithHTML:[urlData autorelease]
                    documentAttributes:nil] 
                   autorelease];
    debug_printf ("htmlpage @ %p\n", htmlpage);

    if (htmlpage) {
        if (mainText) {
            [mainText autorelease];
        }
        mainText = [htmlpage retain];
    }

    if (urlData) {
        debug_printf ("%s for connection %p length %lu\n", __FUNCTION__, connection,
                [urlData length]);

        //        [urlData autorelease];
        //        urlData = nil;
    }

    [self autorelease];
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error 
{
      debug_printf ("%s for connection %p: error %s\n", 
              __FUNCTION__, connection, 
              [[error localizedDescription] UTF8String]);
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
      debug_printf ("%s for connection %p: new request %s\n", 
              __FUNCTION__, connection, 
              [[[request URL] absoluteString] UTF8String]);
      return request;
}

@end
