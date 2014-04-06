//
//  SQExcludedProcessesViewController.h
//  Squeeler
//
//  Created by Brad Greenlee on 4/1/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface SQIgnoredProcessesViewController : NSViewController <MASPreferencesViewController, NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSPanel *addProcessSheet;
    NSArray *runningApplications;
    NSArray *ignoredApplications;
}

@property(nonatomic) IBOutlet NSTableView *ignoredProcessesTable;
@property(nonatomic) IBOutlet NSTableView *processPickerTable;
@property(nonatomic) IBOutlet NSSegmentedCell *addRemoveControl;

- (IBAction)segControlClicked:(id)sender;
- (IBAction)processPickerCancel:(id)sender;
- (IBAction)processPickerSelect:(id)sender;
- (void)saveSettings;

@end
