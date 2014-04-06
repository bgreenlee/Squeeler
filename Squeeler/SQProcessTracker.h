//
//  SQProcessTracker.h
//  Squeeler
//
//  Created by Brad Greenlee on 2/21/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CHECK_INTERVAL 5  // number of seconds between process checks
#define DEFAULT_CPU_USAGE 90  // percent CPU usage before we start counting
#define DEFAULT_ALERT_TIME 60  // number of seconds before we alert
#define DEFAULT_ALERT_RESET 300  // number of seconds before we will alert again on a particular process

@class SQProcessTracker;
@protocol HCProcessTrackerDelegate
- (void) handleProcessAlertWithPid:(pid_t)pid processName:(NSString *)name;
@end //end protocol

@interface SQProcessTracker : NSObject {
    NSMutableDictionary *processes;
    NSMutableDictionary *alertedProcesses;
}
@property (nonatomic, weak) id <HCProcessTrackerDelegate> delegate;
@property (readwrite) NSInteger cpuUsageThreshold;
@property (readwrite) NSInteger alertTime;
@property (readwrite) NSInteger alertReset;
@property (nonatomic) NSSet *ignoredApplications;

- (id)init;
- (id)initWithDelegate:(id <HCProcessTrackerDelegate>)delegate;
- (void)setDelegate:(id <HCProcessTrackerDelegate>)delegate;
- (void)start;
- (NSArray *)runningUniqueApplications;

@end
