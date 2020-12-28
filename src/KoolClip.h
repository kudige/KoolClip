#ifndef __KOOL_CLIP_H__
#define __KOOL_CLIP_H__

/* The controller */
#define CC [ClipController sharedInstance]
#define UD [NSUserDefaults standardUserDefaults]
#define PB [NSPasteboard   generalPasteboard]

/*
 * Key that represents that no hotkey has been set
 */
#define KeyUnset @"DEL"

#define ORIGIN_CENTER  -35

/*
 * Attributes for each clip item
 */
#define ATTRIB_LOCKED @"__attribLocked"


/*
 * Display text in the menu bar.
 * NSNumber
 * TEXT_TYPE_NONE  - No text
 * TEXT_TYPE_COUNT - Display selection count
 */
#define DefaultsTextType            @"TextType"

#define TEXT_TYPE_NONE              0
#define TEXT_TYPE_COUNT             1
#define TEXT_TYPE_SELECTION         2


/*
 * Not used
 */
#define DefaultsShowIcon            @"ShowIcon"

/*
 * Not used
 */
#define DefaultsHistorySize         @"HistorySize"
#define DEFAULT_HISTORY_SIZE        25


/*
 * Show extended text in the menubar
 * If DefaultsTextType is enabled, then show extended text
 * in the menubar.
 * BOOL
 */
#define DefaultsShowExtendedText    @"ShowExtendedText"

/*
 * Icon to be used for normal operation.
 * NSData
 */
#define DefaultsRedIcon             @"NormalIcon"
#define DefaultsBlueIcon            @"FrozenIcon"

/****** Defaults related to saving and loading state *********/
/*
 * Saved list of clipboard history.
 * NSArray of NSDictionary for each item
 */
#define DefaultsClips               @"ClipItemHistory"

/*
 * Saved selection
 * NSNumber
 */
#define DefaultsSelection           @"ClipSelection"

/*
 * Saved "frozen" state
 * BOOL
 */
#define DefaultsFrozen              @"SelectionFrozen"

/*
 * Saved change count from the pasteboard.
 * Used for deciding to load the pb data
 * after a restart.
 * NSNumber
 */
#define DefaultsChangeCount         @"ChangeCount"


/******* Defaults for Flash Window ***********/

/*
 * Position of the window:
 * NSNumber, NSNumber
 */
#define DefaultsFlashX              @"OriginX"
#define DefaultsFlashY              @"OriginY"

#define FLASH_ORIGINX  ORIGIN_CENTER
#define FLASH_ORIGINY  ORIGIN_CENTER

/*
 * Size of the window:
 * NSNumber, NSNumber
 */
#define DefaultsFlashWidth          @"FlashWidth"
#define DefaultsFlashHeight         @"FlashHeight"
#define FLASH_WIDTH  400
#define FLASH_HEIGHT 400


/*
 * Transparency : 
 * NSNumber (float)
 */
#define DefaultsFlashAlpha          @"FlashAlpha"
#define FLASH_ALPHA  0.6

/*
 * Delay of the flash window
 * NSNumber (float) in seconds
 */
#define DefaultsFlashDelay          @"FlashDelay"
#define FLASH_DELAY  3.0

/*
 * Color : 
 * Triplet of NSNumber(float)
 */
#define DefaultsFlashColorRed       @"FlashColorRed"
#define DefaultsFlashColorGreen     @"FlashColorGreen"
#define DefaultsFlashColorBlue      @"FlashColorBlue"
#define FLASH_COLOR_RED    0.2
#define FLASH_COLOR_GREEN  0.2
#define FLASH_COLOR_BLUE   0.4

/****** URL related defaults **********/

/*
 * Display preview of the HTML content for URLs
 * BOOL
 */
#define DefaultsUrlPreview          @"URLPreview"
#define shouldUrlPreview ([UD boolForKey:DefaultsUrlPreview])

/*
 * Load html page and use it for keyword search
 * BOOL
 */
#define DefaultsUrlKeywords         @"URLLoadKeywords"
#define shouldUrlKeywords ([UD boolForKey:DefaultsUrlKeywords])

/*
 * Truncate the html page to this many bytes.
 * Speeds up search and makes KoolClip more responsive
 * NSNumber
 */
#define DefaultsUrlMaxData          @"URLMaxData"

#define URL_MAXDATA        5000


/* 
 * Defaults for HotKeys 
 *
 * For each action Keycode and Modifier pair as NSNumber(int)
 */
#define DefaultsKeyPrev             @"KeyPrev"
#define DefaultsModPrev             @"ModPrev"

#define DefaultsKeyNext             @"KeyNext"
#define DefaultsModNext             @"ModNext"

#define DefaultsKeyCurr             @"KeyCurr"
#define DefaultsModCurr             @"ModCurr"

#define DefaultsKeyLock             @"KeyLock"
#define DefaultsModLock             @"ModLock"

#define DefaultsKeyPrefs            @"KeyPrefs"
#define DefaultsModPrefs            @"ModPrefs"

#define DefaultsKeySearch           @"KeySearch"
#define DefaultsModSearch           @"ModSearch"

#define DefaultsKeyClear            @"KeyClear"
#define DefaultsModClear            @"ModClear"

#define DefaultsKeyQuit             @"KeyQuit"
#define DefaultsModQuit             @"ModQuit"

#define DefaultsKeyGoogle           @"KeyGoogle"
#define DefaultsModGoogle           @"ModGoogle"


/* Application and Menu Bar Icons */
#define MenuTextHelp        @"Help"
#define MenuTextAbout       @"About KoolClip"
#define MenuTextSupport     @"Support KoolClip"

#define MenuTextPrev        @"Select Previous Clip"
#define MenuTextNext        @"Select Next Clip"
#define MenuTextFreeze      @"Freeze Current Selection"
#define MenuTextUnfreeze    @"Unfreeze Current Selection"

#define MenuTextWantText    @"Show text in Menu Bar"
#define MenuTextHideText    @"Hide text in Menu Bar"

#define MenuTextPrefs       @"Preferences"
#define MenuTextSearch      @"QuickSearch History"

#define MenuTextClear       @"Clear All Items"
#define MenuTextQuit        @"Quit Koolclip"

/* Max length of chars in the menu */
#define CLIP_LENGTH         40

#define MENU_ICON_WIDTH    50
#define MENU_ICON_HEIGHT   50


#define RED_ICON   @"PaperClipRed.pdf"
#define BLUE_ICON  @"PaperClipBlue.pdf"

#define RedIcon  [CC unlockedIcon]
#define BlueIcon [CC lockedIcon]

/* Clip Item Flash View */
#define FLASH_IMAGE_THRES  100
#define FLASH_IMAGE_WIDTH  600
#define FLASH_IMAGE_HEIGHT 600

#define FLASH_LARGE_WIDTH  300
#define FLASH_LARGE_HEIGHT 300

#define FLASH_SMALL_WIDTH  90
#define FLASH_SMALL_HEIGHT 90

#define DefaultsFramePrefs  @"FramePrefs"
#define DefaultsFrameSearch @"FrameSearch"

#define URLSupport @"http://www.kudang.com/support"
#define URLHelp @"http://www.kudang.com/koolclip/help"
#define URLGoogle @"http://www.kudang.com/koolclip/google.php?search=%s"
#define URLBlog @"http://technosophyunlimited.blogspot.com/"

#define HelpFlashGuide @"Move this window and resize it to customize." 
#define HelpPressKeyCombo @"Press the key combination you want to assign as hotkey\nor press DELETE key to remove the hotkey."
/* Title for the cancel button when UI dirty and not */
#define StringClose  @"Close"
#define StringCancel @"Cancel"

/* Alert dialog when closing preferences without saving changes */
#define StringSaveMessage @"Do you want to save preferences before closing?"
#define StringSaveInformative @"If you don't save, your changes will be lost"

/* Debug support */
#ifdef DEBUG
#define debug_printf printf
#else
#define debug_printf noprintf
#endif

int noprintf(const char *fmt, ...);

const extern NSSize ClipItemFlashWindowSize;

#endif
