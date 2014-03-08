//
//  HCAppDelegate.m
//  HogCaller
//
//  Created by Brad Greenlee on 2/19/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "HCAppDelegate.h"

@implementation HCAppDelegate
@synthesize aboutWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    processTracker = [[HCProcessTracker alloc] initWithDelegate:self];
    [processTracker start];
}

- (void)awakeFromNib {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"statusbar" ofType:@"png"]];
    [statusItem setImage:statusImage];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"statusbar-alternate" ofType:@"png"]];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Squeeler"];
    [statusItem setHighlightMode:YES];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    [center removeDeliveredNotification:notification];
    pid_t pid = [[[notification userInfo] objectForKey:@"pid"] intValue];
    NSLog(@"Clicked on notification with pid %i", pid);
    [[NSWorkspace sharedWorkspace] launchApplication:@"Activity Monitor"];
}

- (void) handleProcessAlertWithPid:(pid_t)pid {
    NSLog(@"Process %i is a hog!", pid);
    // get application info
    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:pid] forKey:@"pid"];
    NSString *name = app.localizedName;
    if (name == nil) {
        name = [NSString stringWithFormat:@"Process #%i", pid];
    }
    notification.title = [NSString stringWithFormat:@"CPU Hog: %@", name];
    notification.informativeText = [NSString stringWithFormat:@"%@ is hogging CPU.", name];
    notification.contentImage = app.icon;
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
}

- (IBAction)showAbout:(id)sender {
    if (aboutWindowController == nil) {
        aboutWindowController = [[HCAboutWindowController alloc] init];
    }
    [aboutWindowController showWindow:self];
    [[aboutWindowController window] setReleasedWhenClosed:NO];
}

@end
