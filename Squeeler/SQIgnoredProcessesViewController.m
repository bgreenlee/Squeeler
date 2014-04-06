//
//  SQExcludedProcessesViewController.m
//  Squeeler
//
//  Created by Brad Greenlee on 4/1/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQIgnoredProcessesViewController.h"
#import "SQAppDelegate.h"
#import "SQApplication.h"

@interface SQIgnoredProcessesViewController ()

@end

@implementation SQIgnoredProcessesViewController
@synthesize ignoredProcessesTable;
@synthesize processPickerTable;
@synthesize addRemoveControl;

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier {
    return @"Ignored";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:@"subtract"];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"Ignored", @"Toolbar item name for ignored processes");
}

#pragma mark -

- (id)init {
    return [super initWithNibName:@"SQIgnoredProcessesView" bundle:nil];
}

- (void)awakeFromNib {
    SQAppDelegate *appDelegate = (SQAppDelegate *)[NSApp delegate];
    runningApplications = [appDelegate.processTracker runningUniqueApplications];
    [ignoredProcessesTable setDelegate:self];
    [self loadSettings];
}

- (void)loadSettings {
    NSArray *ignoredApplicationPaths = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ignoredApplications"];
    if (ignoredApplicationPaths == nil) {
        ignoredApplications = [[NSArray alloc] init];
    } else {
        ignoredApplications = [SQApplication applicationsFromPaths:ignoredApplicationPaths];
    }
}

- (void)saveSettings {
    // we can't store the SQApplication objects, so extract the paths
    NSArray *applicationPaths = [ignoredApplications valueForKey:@"path"];
    [[NSUserDefaults standardUserDefaults] setObject:applicationPaths forKey:@"ignoredApplications"];
    [[NSApp delegate] updateIgnoredApplicationsWithArray:applicationPaths];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    BOOL shouldEnableRemove = [ignoredProcessesTable numberOfSelectedRows] > 0;
    [addRemoveControl setEnabled:shouldEnableRemove forSegment:1];
}

- (IBAction)segControlClicked:(id)sender {
    NSInteger clickedSegment = [sender selectedSegment];
    NSInteger clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if (clickedSegmentTag == 0) {
        [self showTheSheet];
    } else {
        NSMutableSet *ignoredAppsSet = [[NSMutableSet alloc] initWithArray:ignoredApplications];
        [[ignoredProcessesTable selectedRowIndexes] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [ignoredAppsSet removeObject:[ignoredApplications objectAtIndex:idx]];
        }];
        // update ignored apps list
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        ignoredApplications = [ignoredAppsSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        [ignoredProcessesTable reloadData];
    }
}

- (void)showTheSheet {
    [processPickerTable deselectAll:nil];
    [NSApp beginSheet:addProcessSheet
       modalForWindow:(NSWindow *)self.view.window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

-(void)endTheSheet:(id)sender {
    [NSApp endSheet:addProcessSheet];
    [addProcessSheet orderOut:sender];
}

- (IBAction)processPickerCancel:(id)sender {
    [self endTheSheet:sender];
}

- (IBAction)processPickerSelect:(id)sender {
    NSMutableSet *ignoredAppsSet = [[NSMutableSet alloc] initWithArray:ignoredApplications];
    [[processPickerTable selectedRowIndexes] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [ignoredAppsSet addObject:[runningApplications objectAtIndex:idx]];
    }];
    // update ignored apps list
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    ignoredApplications = [ignoredAppsSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    [ignoredProcessesTable reloadData];
    [self endTheSheet:sender];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([tableView.identifier isEqualToString:@"ignoredProcesses"]) {
        return [ignoredApplications count];
    } else {
        return [runningApplications count];
    }
}

// since we have two tables to deal with, and one controller, we have to multiplex them
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableView.identifier isEqualToString:@"ignoredProcesses"]) {
        return [self ignoredProcessesTableObjectValueForTableColumn:tableColumn row:row];
    } else {
        return [self processPickerTableObjectValueForTableColumn:tableColumn row:row];
    }
}

- (id)ignoredProcessesTableObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"name"]) {
        return [[ignoredApplications objectAtIndex:row] name];
    } else {
        return [[ignoredApplications objectAtIndex:row] icon];
    }
}

- (id)processPickerTableObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"name"]) {
        return [[runningApplications objectAtIndex:row] name];
    } else {
        return [[runningApplications objectAtIndex:row] icon];
    }
}
@end
