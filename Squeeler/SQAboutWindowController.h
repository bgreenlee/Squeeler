//
//  SQAboutWindowController.h
//  Squeeler
//
//  Created by Brad Greenlee on 2/23/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSAttributedString+Hyperlink.h"

@interface SQAboutWindowController : NSWindowController <HyperlinkTextFieldDelegate>

@property(nonatomic) IBOutlet NSTextField *version;
@property(nonatomic) IBOutlet HyperlinkTextField *homepageLink;

- (void)linkClicked:(id)sender;

@end
