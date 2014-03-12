//
//  SQPreferencesWindowController.h
//  Squeeler
//
//  Created by Brad Greenlee on 3/8/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define DEFAULT_CPU_USAGE 90  // percent CPU usage before we start counting
#define DEFAULT_ALERT_TIME 60  // number of seconds before we alert
#define DEFAULT_ALERT_RESET 300  // number of seconds before we will alert again on a particular process

@interface SQPreferencesWindowController : NSWindowController <NSWindowDelegate> {
    NSArray *alertTimeTickMap;
    NSArray *alertResetTickMap;
}

@property(nonatomic) IBOutlet NSSlider *cpuUsageSlider;
@property(nonatomic) IBOutlet NSTextField *cpuUsageText;
@property(nonatomic) IBOutlet NSSlider *alertTimeSlider;
@property(nonatomic) IBOutlet NSTextField *alertTimeText;
@property(nonatomic) IBOutlet NSSlider *alertResetSlider;
@property(nonatomic) IBOutlet NSTextField *alertResetText;
@property(nonatomic) IBOutlet NSButton *startAtLogin;

- (IBAction)cpuUsageSliderChanged:(id)sender;
- (IBAction)alertTimeSliderChanged:(id)sender;
- (IBAction)alertResetSliderChanged:(id)sender;
//- (IBAction)onClose:(id)sender;

@end
