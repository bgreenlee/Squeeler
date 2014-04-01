//
//  SQAboutWindowController.m
//  Squeeler
//
//  Created by Brad Greenlee on 2/23/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQAboutViewController.h"

@interface SQAboutViewController ()

@end

@implementation SQAboutViewController
@synthesize version;
@synthesize homepageLink;
@synthesize parentWindow;

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier {
    return @"About";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:@"AppIcon"];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"About", @"Toolbar item name for the about pane");
}

#pragma mark -
#pragma mark SQAboutViewController

- (id)init {
    self = [super initWithNibName:@"SQAboutView" bundle:nil];
    return self;
}

- (void)awakeFromNib {
    // set version
    NSString *semanticVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [version setStringValue:[NSString stringWithFormat:@"%@ build %@", semanticVersion, build]];

    // linkify text
    [homepageLink setAttributedStringValue:
     [NSAttributedString hyperlinkFromString:@"http://footle.org/Squeeler"
                                     withURL:[NSURL URLWithString:@"http://footle.org/Squeeler/"]]];
    homepageLink.linkDelegate = self;
}

- (void)linkClicked:(id)sender {
    [parentWindow close];
}

@end
