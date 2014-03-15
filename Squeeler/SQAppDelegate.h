//
//  SQAppDelegate.h
//  Squeeler
//
//  Created by Brad Greenlee on 2/19/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SQProcessTracker.h"
#import "SQPreferencesWindowController.h"
#import "SQAboutWindowController.h"

@interface SQAppDelegate : NSObject <NSApplicationDelegate, HCProcessTrackerDelegate, NSUserNotificationCenterDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    SQProcessTracker *processTracker;
}

- (void) updateSettingsWithCpuUsage:(NSInteger)cpuUsage
                          alertTime:(NSInteger)alertTime
                         alertReset:(NSInteger)alertReset;
- (IBAction) showPreferences:(id)sender;
- (IBAction) showAbout:(id)sender;

@property (strong) SQPreferencesWindowController* preferencesWindowController;
@property (strong) SQAboutWindowController* aboutWindowController;
@end
