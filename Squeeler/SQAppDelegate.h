//
//  SQAppDelegate.h
//  Squeeler
//
//  Created by Brad Greenlee on 2/19/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SQProcessTracker.h"
#import "SQAboutWindowController.h"

@interface SQAppDelegate : NSObject <NSApplicationDelegate, HCProcessTrackerDelegate, NSUserNotificationCenterDelegate, NSUserNotificationCenterDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    SQProcessTracker *processTracker;
}

- (IBAction)showAbout:(id)sender;

//@property (assign) IBOutlet NSWindow *window;
@property (strong) SQAboutWindowController* aboutWindowController;
@end
