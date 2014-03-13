//
//  SQAppDelegate.m
//  SqueelerLaunchAtLogin
//
//  Created by Brad Greenlee on 3/11/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQAppDelegate.h"

@implementation SQAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Check if main app is already running; if yes, do nothing and terminate helper app
    BOOL alreadyRunning = NO;
    BOOL isActive = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running) {
        NSLog(@"running: %@", [app bundleIdentifier]);
        if ([[app bundleIdentifier] isEqualToString:@"com.hackarts.Squeeler"]) {
            alreadyRunning = YES;
            isActive = [app isActive];
        }
    }
    
    if (!alreadyRunning || !isActive) {
        NSLog(@"not running so launching...");
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSArray *p = [path pathComponents];
        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents addObject:@"MacOS"];
        [pathComponents addObject:@"Squeeler"];
        NSString *newPath = [NSString pathWithComponents:pathComponents];
        NSLog(@"newPath: %@", newPath);
        [[NSWorkspace sharedWorkspace] launchApplication:newPath];
    }
    [NSApp terminate:nil];
}

@end
