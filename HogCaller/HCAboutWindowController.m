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
    NSString *_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [version setStringValue:_version];
    
    [self.window center];
}

@end
