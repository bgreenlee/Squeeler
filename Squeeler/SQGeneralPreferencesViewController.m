//
//  SQPreferencesWindowController.m
//  Squeeler
//
//  Created by Brad Greenlee on 3/8/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQGeneralPreferencesViewController.h"
#import "LaunchAtLoginController.h"
#import "SQAppDelegate.h"

@interface SQGeneralPreferencesViewController ()

@end

@implementation SQGeneralPreferencesViewController
@synthesize cpuUsageSlider, cpuUsageText;
@synthesize alertTimeSlider, alertTimeText;
@synthesize alertResetSlider, alertResetText;
@synthesize launchAtLoginCheckbox;

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier {
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"General", @"Toolbar item name for the general preferences pane");
}

#pragma mark -
#pragma mark SQGeneralPreferencesViewController

- (id)init {
    self = [super initWithNibName:@"SQGeneralPreferencesView" bundle:nil];
    alertTimeTickMap = @[@5, @10, @15, @30, @45, @60, @90, @120, @180, @300, @600, @900, @1800, @3600, @7200, @10800];
    alertResetTickMap = @[@5, @10, @15, @30, @45, @60, @90, @120, @180, @300, @600, @900, @1800, @3600, @7200, @10800];
    return self;
}

- (void)awakeFromNib {
    [self loadSettings];
}

- (void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSInteger cpuUsage = [defaults integerForKey:@"cpuUsage"];
    if (cpuUsage == 0) {
        cpuUsage = DEFAULT_CPU_USAGE;
    }
    [self.cpuUsageSlider setIntegerValue:cpuUsage];
    [self updateCpuUsageText:cpuUsage];
    
    NSInteger alertTime = [defaults integerForKey:@"alertTime"];
    if (alertTime == 0) {
        alertTime = DEFAULT_ALERT_TIME;
    }
    // lookup time in map
    NSInteger i = 0;
    for (; i < [alertTimeTickMap count]; i++) {
        NSNumber *tickMapValue = [alertTimeTickMap objectAtIndex:i];
        if ([tickMapValue integerValue] >= alertTime) {
            break;
        }
    }
    [self.alertTimeSlider setIntegerValue:i];
    [self updateAlertTimeText:alertTime];

    
    NSInteger alertReset = [defaults integerForKey:@"alertReset"];
    if (alertReset == 0) {
        alertReset = DEFAULT_ALERT_RESET;
    }
    for (i = 0; i < [alertResetTickMap count]; i++) {
        NSNumber *tickMapValue = [alertResetTickMap objectAtIndex:i];
        if ([tickMapValue integerValue] >= alertReset) {
            break;
        }
    }
    [self.alertResetSlider setIntegerValue:i];
    [self updateAlertResetText:alertReset];

    // set launch at login
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launchAtLoginEnabled = [launchController launchAtLogin];
    [launchAtLoginCheckbox setState:launchAtLoginEnabled ? NSOnState : NSOffState];
}

- (void)saveSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger cpuUsage = [cpuUsageSlider integerValue];
    [defaults setInteger:cpuUsage forKey:@"cpuUsage"];
    NSInteger alertTimeTick = [alertTimeSlider integerValue];
    NSInteger alertTime = [[alertTimeTickMap objectAtIndex:alertTimeTick] integerValue];
    [defaults setInteger:alertTime forKey:@"alertTime"];
    NSInteger alertResetTick = [alertResetSlider integerValue];
    NSInteger alertReset = [[alertResetTickMap objectAtIndex:alertResetTick] integerValue];
    [defaults setInteger:alertReset forKey:@"alertReset"];

    // save launch at login preference
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launchOnLoginEnabled = [launchAtLoginCheckbox state] == NSOnState;
	[launchController setLaunchAtLogin:launchOnLoginEnabled];
    
    [[NSApp delegate] updateSettingsWithCpuUsage:cpuUsage alertTime:alertTime alertReset:alertReset];
}

- (IBAction)cpuUsageSliderChanged:(id)sender {
    [self updateCpuUsageText:[cpuUsageSlider integerValue]];
}

- (IBAction)alertTimeSliderChanged:(id)sender {
    NSInteger tick = [alertTimeSlider integerValue];
    NSInteger alertTime = [[alertTimeTickMap objectAtIndex:tick] integerValue];
    [self updateAlertTimeText:alertTime];
}

- (IBAction)alertResetSliderChanged:(id)sender {
    NSInteger tick = [alertResetSlider integerValue];
    NSInteger alertReset = [[alertResetTickMap objectAtIndex:tick] integerValue];
    [self updateAlertResetText:alertReset];
}

- (void)updateCpuUsageText:(NSInteger)value {
    [cpuUsageText setStringValue:[NSString stringWithFormat:@"%ld%%", value]];
}

- (void)updateAlertTimeText:(NSInteger)value {
    [alertTimeText setStringValue:[self friendlyTime:value]];
}

- (void)updateAlertResetText:(NSInteger)value {
    [alertResetText setStringValue:[self friendlyTime:value]];
}

- (NSString *)friendlyTime:(NSInteger)seconds {
    NSString *resultStr;
    NSInteger remainder = 0;
    if (seconds >= 3600) {
        NSInteger hours = seconds / 3600;
        resultStr = [NSString stringWithFormat:@"%ld %@", hours, hours == 1 ? @"hour" : @"hours"];
        remainder = seconds - hours * 3600;
    } else if (seconds >= 60) {
        NSInteger minutes = seconds / 60;
        resultStr = [NSString stringWithFormat:@"%ld %@", (long)minutes, minutes == 1 ? @"minute" : @"minutes"];
        remainder = seconds - minutes * 60;
    } else {
        resultStr = [NSString stringWithFormat:@"%ld %@", seconds, seconds == 1 ? @"second" : @"seconds"];
    }
    
    if (remainder > 0) {
        resultStr = [NSString stringWithFormat:@"%@, %@", resultStr, [self friendlyTime:remainder]];
    }

    return resultStr;
}
@end
