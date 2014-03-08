//
//  SQProcessTracker.h
//  Squeeler
//
//  Created by Brad Greenlee on 2/21/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CHECK_INTERVAL 5  // number of seconds between process checks
#define CPU_THRESHOLD 10  // percent CPU usage before we start counting
#define COUNTER_THRESHOLD 1  // number of CHECK_INTERVAL "ticks" before we alert
#define ALERT_RESET_TIMEOUT 300  // number of seconds before we will alert again on a particular process

@class SQProcessTracker;
@protocol HCProcessTrackerDelegate
- (void) handleProcessAlertWithPid:(pid_t)pid;
@end //end protocol

@interface SQProcessTracker : NSObject {
    NSMutableDictionary *processes;
    NSMutableDictionary *alertedProcesses;
}
@property (nonatomic, weak) id <HCProcessTrackerDelegate> delegate;

- (id)init;
- (id)initWithDelegate:(id <HCProcessTrackerDelegate>)delegate;
- (void)setDelegate:(id <HCProcessTrackerDelegate>)delegate;
- (void)start;

@end
