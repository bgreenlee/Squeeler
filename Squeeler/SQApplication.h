//
//  SQApplication.h
//  Squeeler
//
//  Created by Brad Greenlee on 4/5/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQApplication : NSObject
@property(nonatomic) NSString *path;
@property(nonatomic) NSImage *icon;

- (id)initWithPath:(NSString *)path;
- (NSString *)name;
+ (NSArray *)applicationsFromPaths:(NSArray *)paths;

@end
