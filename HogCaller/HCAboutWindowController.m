//
//  HCAboutWindowController.m
//  HogCaller
//
//  Created by Brad Greenlee on 2/23/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "HCAboutWindowController.h"

@interface HCAboutWindowController ()

@end

@implementation HCAboutWindowController
@synthesize version;

- (id)init {
    self = [super initWithWindowNibName:@"HCAboutWindow"];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    // set version
    NSString *semanticVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [version setStringValue:[NSString stringWithFormat:@"%@ build %@", semanticVersion, build]];
    
    [self.window center];
}

@end
