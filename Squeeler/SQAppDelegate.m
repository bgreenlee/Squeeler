//
//  SQAppDelegate.m
//  Squeeler
//
//  Created by Brad Greenlee on 2/19/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQAppDelegate.h"

#define RECENT_HOGS_TAG 1
#define MAX_RECENT_HOGS 5

@implementation SQAppDelegate
@synthesize preferencesWindowController;
@synthesize aboutWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [NSApp setDelegate:self];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [statusMenu setDelegate:self];
    processTracker = [[SQProcessTracker alloc] initWithDelegate:self];
    [processTracker start];
}

- (void)awakeFromNib {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"statusbar"]];
    [statusItem setAlternateImage:[NSImage imageNamed:@"statusbar-alternate"]];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Squeeler"];
    [statusItem setHighlightMode:YES];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification
{
    [center removeDeliveredNotification:notification];
    [statusItem setImage:[NSImage imageNamed:@"statusbar"]];
//    pid_t pid = [[[notification userInfo] objectForKey:@"pid"] intValue];
//    NSLog(@"Clicked on notification with pid %i", pid);
    [[NSWorkspace sharedWorkspace] launchApplication:@"Activity Monitor"];
}

- (void) handleProcessAlertWithPid:(pid_t)pid processName:(NSString *)name {
    NSLog(@"Process %i is a hog!", pid);
    // get application info
    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:pid] forKey:@"pid"];
    notification.title = [NSString stringWithFormat:@"CPU Hog: %@", name];
    notification.informativeText = [NSString stringWithFormat:@"%@ (%d) is hogging CPU.", name, pid];
    notification.contentImage = app.icon;
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

    [self updateRecentHogsMenuWithProcessString:[NSString stringWithFormat:@"%@ (%d)", name, pid] image:app.icon];
    [statusItem setImage:[NSImage imageNamed:@"statusbar-alerted"]];
}

- (void) updateSettingsWithCpuUsage:(NSInteger)cpuUsage
                          alertTime:(NSInteger)alertTime
                         alertReset:(NSInteger)alertReset {
    processTracker.cpuUsageThreshold = cpuUsage;
    processTracker.alertTime = alertTime;
    processTracker.alertReset = alertReset;
}

- (void) menuWillOpen:(NSMenu *)menu {
    // clear alert status
    [statusItem setImage:[NSImage imageNamed:@"statusbar"]];
}

- (void) updateRecentHogsMenuWithProcessString:(NSString *)processStr image:(NSImage *)image {
    NSMenu *recentHogsMenu = [[statusMenu itemWithTag:RECENT_HOGS_TAG] submenu];
    if ([recentHogsMenu itemWithTitle:@"None"] != nil) {
        [recentHogsMenu removeAllItems];
    }
    NSMenuItem *newMenuItem = [[NSMenuItem alloc] init];
    newMenuItem.title = processStr;
    if (image) {
        newMenuItem.image = image;
    } else {
        [newMenuItem setIndentationLevel:3];
    }
    [newMenuItem setEnabled:NO];
    [recentHogsMenu insertItem:newMenuItem atIndex:0];
    if ([recentHogsMenu numberOfItems] > MAX_RECENT_HOGS) {
        [recentHogsMenu removeItemAtIndex:MAX_RECENT_HOGS];
    }
}

- (IBAction) showPreferences:(id)sender {
    if (preferencesWindowController == nil) {
        preferencesWindowController = [[SQPreferencesWindowController alloc] init];
    }
    [preferencesWindowController showWindow:self];
    [preferencesWindowController.window setReleasedWhenClosed:NO];
    [preferencesWindowController.window center];
    [preferencesWindowController.window setLevel: NSMainMenuWindowLevel];
}

- (IBAction) showAbout:(id)sender {
    if (aboutWindowController == nil) {
        aboutWindowController = [[SQAboutWindowController alloc] init];
    }
    [aboutWindowController showWindow:self];
    [aboutWindowController.window setReleasedWhenClosed:NO];
    [aboutWindowController.window center];
    [aboutWindowController.window setLevel: NSMainMenuWindowLevel];
}

@end
