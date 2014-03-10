//
//  SQPreferencesWindowController.h
//  Squeeler
//
//  Created by Brad Greenlee on 3/8/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SQPreferencesWindowController : NSWindowController

@property(nonatomic) IBOutlet NSSlider *cpuUsageSlider;
@property(nonatomic) IBOutlet NSTextField *cpuUsageText;
@property(nonatomic) IBOutlet NSSlider *alertTimeSlider;
@property(nonatomic) IBOutlet NSTextField *alertTimeText;
@property(nonatomic) IBOutlet NSSlider *alertResetSlider;
@property(nonatomic) IBOutlet NSTextField *alertResetText;
@property(nonatomic) IBOutlet NSButton *startAtLogin;

@end
