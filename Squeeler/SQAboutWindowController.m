//
//  SQAboutWindowController.m
//  Squeeler
//
//  Created by Brad Greenlee on 2/23/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQAboutWindowController.h"

@interface SQAboutWindowController ()

@end

@implementation SQAboutWindowController
@synthesize version;
@synthesize homepageLink;

- (id)init {
    self = [super initWithWindowNibName:@"SQAboutWindow"];
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

    [self.window center];
}

- (void)linkClicked:(id)sender {
    // close the about window
    [self.window close];
}

@end
