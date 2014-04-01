//
//  SQPreferencesWindowController.h
//  Squeeler
//
//  Created by Brad Greenlee on 3/27/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "MASPreferencesWindowController.h"
#import "SQGeneralPreferencesViewController.h"
#import "SQAboutViewController.h"

@interface SQPreferencesWindowController : MASPreferencesWindowController {
    SQGeneralPreferencesViewController *generalPreferencesViewController;
    SQAboutViewController *aboutViewController;
}

@end
