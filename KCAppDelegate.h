//
//  KCAppDelegate.h
//  KoolClip
//
//  Created by Chandan Kudige on 1/11/11.
//  Copyright (c) 2011 Kudang Technologies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
