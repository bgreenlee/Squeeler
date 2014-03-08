//
//  HCAppDelegate.h
//  HogCaller
//
//  Created by Brad Greenlee on 2/19/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HCProcessTracker.h"
#import "HCAboutWindowController.h"

@interface HCAppDelegate : NSObject <NSApplicationDelegate, HCProcessTrackerDelegate, NSUserNotificationCenterDelegate, NSUserNotificationCenterDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    HCProcessTracker *processTracker;
}

- (IBAction)showAbout:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (strong) HCAboutWindowController* aboutWindowController;
@end
