//
//  SQPreferencesWindowController.m
//  Squeeler
//
//  Created by Brad Greenlee on 3/27/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQPreferencesWindowController.h"

@interface SQPreferencesWindowController ()

@end

@implementation SQPreferencesWindowController

- (id)init {
    SQGeneralPreferencesViewController *_generalPreferencesViewController = [[SQGeneralPreferencesViewController alloc] init];
    SQAboutViewController *_aboutViewController = [[SQAboutViewController alloc] init];
    NSArray *controllers = [[NSArray alloc] initWithObjects:_generalPreferencesViewController, _aboutViewController, nil];
    NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
    if ((self = [super initWithViewControllers:controllers title:title])) {
        generalPreferencesViewController = _generalPreferencesViewController;
        aboutViewController = _aboutViewController;
        aboutViewController.parentWindow = self.window;
    }
    return self;
}

- (void)showWindow:(id)sender {
    [[self window] center];
    [self selectControllerAtIndex:0]; // always show General prefs on startup
    [NSApp activateIgnoringOtherApps:YES];
    [super showWindow:sender];
}

-(BOOL)windowShouldClose:(id)sender {
#pragma unused (sender)
    [generalPreferencesViewController saveSettings];
    return YES;
}

@end
