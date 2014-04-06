//
//  SQApplication.m
//  Squeeler
//
//  Created by Brad Greenlee on 4/5/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQApplication.h"

@implementation SQApplication
@synthesize path;
@synthesize icon;

- (id)initWithPath:(NSString *)_path {
    if ((self = [super init])) {
        self.path = _path;
        // hacky way to get the path to the .app itself, rather than the executable within it
        NSRange range = [_path rangeOfString:@".app/"];
        if (range.location != NSNotFound) {
            _path = [_path substringToIndex:range.location + range.length - 1];
        }
        self.icon = [[NSWorkspace sharedWorkspace] iconForFile:_path];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == nil || ![object isKindOfClass:[SQApplication class]]) {
        return NO;
    }
    
    return [((SQApplication *)object).name isEqualToString:self.name];
}

- (NSUInteger)hash {
    return [self.name hash];
}

- (NSString *)name {
    return [[path componentsSeparatedByString:@"/"] lastObject];
}

/* return an array of SQApplication objects from the given application paths */
+ (NSArray *)applicationsFromPaths:(NSArray *)paths {
    NSMutableArray *apps = [[NSMutableArray alloc] initWithCapacity:[paths count]];
    for (NSString *path in paths) {
        [apps addObject:[[SQApplication alloc] initWithPath:path]];
    }
    return apps;
}

@end
