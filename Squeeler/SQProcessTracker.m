//
//  SQProcessTracker.m
//  Squeeler
//
//  Created by Brad Greenlee on 2/21/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQProcessTracker.h"

@implementation SQProcessTracker
@synthesize delegate;

- (id)init {
    if ((self = [super init])) {
        processes = [[NSMutableDictionary alloc] init];
        alertedProcesses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithDelegate:(id<HCProcessTrackerDelegate>)aDelegate {
    id myself = [self init];
    [myself setDelegate:aDelegate];
    return myself;
}

- (void)setDelegate:(id <HCProcessTrackerDelegate>)aDelegate {
    delegate = aDelegate;
}

- (void)start {
    NSTask *task = [[NSTask alloc] init];
    // launch top -R -s CHECK_INTERVAL -l 0 -stats "pid, cpu"
    [task setLaunchPath:@"/usr/bin/top"];
    [task setArguments:[NSArray arrayWithObjects:@"-R", @"-s", [NSString stringWithFormat:@"%i", CHECK_INTERVAL], @"-l", @"0", @"-stats", @"pid, cpu", nil]];
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    NSFileHandle *fh = [outputPipe fileHandleForReading];
    [fh waitForDataInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedTopData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:fh];
    [task launch];
}

- (void)receivedTopData:(NSNotification *)notification {
    NSFileHandle *fh = [notification object];
    NSData *data = [fh availableData];
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self updateProcessStatus:[self parseTopData:dataStr]];
    [fh waitForDataInBackgroundAndNotify];
}

// Parse the output from top and return a dictionary of processes that are over the cpu threshold
- (NSDictionary *)parseTopData:(NSString *)topData {
    // top output that we care about looks like:
    // 12345   0.1
    // 12346-  11.7
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*(\\d+)[-+*]?\\s+(\\d+)\\.\\d+\\s*$"
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    if (error != nil) {
        NSLog(@"Parsing error: %@", error);
    }
    NSArray *matches = [regex matchesInString:topData options:0 range:NSMakeRange(0, [topData length])];
    NSMutableDictionary *processStatus = [[NSMutableDictionary alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSString *pid = [topData substringWithRange:[match rangeAtIndex:1]];
        NSInteger cpu = [[topData substringWithRange:[match rangeAtIndex:2]] integerValue];
        if (![pid isEqual: @"0"]) { // ignore the kernel_task
            [processStatus setValue:[NSNumber numberWithInteger:cpu] forKey:pid];
        }
    }
    return processStatus;
}

- (void)updateProcessStatus:(NSDictionary *)lastProcessStatus {
    /*
     Iterate through the process dict:
       - if the process is in lastProcessStatus,
            - if lastProcesStatus cpu is over threshold, increment the counter
                if the counter > threshold, send notification (and reset counter to 0?)
            - else decrement the counter
       - else delete from process dict
     Iterate through lastProcessStatus and add any entries that aren't in processes
     */
    [processes enumerateKeysAndObjectsUsingBlock:^(id pid, id counter, BOOL *stop) {
        NSNumber *lastCPU = [lastProcessStatus objectForKey:pid];
        if (lastCPU == nil) {
            [processes removeObjectForKey:pid]; // not in the latest process update, so remove it
        } else {
            NSInteger intCounter = [(NSNumber *)counter integerValue];
            if ([lastCPU integerValue] > CPU_THRESHOLD) {
                if (intCounter >= COUNTER_THRESHOLD) {
                    // check that we haven't alerted on this process recently
                    NSDate *lastAlert = [alertedProcesses objectForKey:pid];
                    if (lastAlert == nil || [lastAlert timeIntervalSinceNow] < -ALERT_RESET_TIMEOUT) {
                        [alertedProcesses setObject:[NSDate date] forKey:pid];
                        [delegate handleProcessAlertWithPid:[pid intValue]];  // send notification
                    }
                    [processes setValue:[NSNumber numberWithInteger:0] forKey:pid]; // reset so we're not continually spamming
                } else {
                    NSLog(@"Bumping counter for %@ up to %li", pid, intCounter + 1);
                    [processes setValue:[NSNumber numberWithInteger:intCounter + 1] forKey:pid];
                }
            } else if (intCounter > 0) {
                NSLog(@"Decrementing counter for %@ down to %li", pid, intCounter - 1);
                [processes setValue:[NSNumber numberWithInteger:intCounter - 1] forKey:pid];
            }
        }
    }];
    
    // add any new entries
    NSSet *newPids = [lastProcessStatus keysOfEntriesPassingTest:^BOOL(id pid, id cpu, BOOL *stop) {
        return [processes objectForKey:pid] == nil;
    }];
    [newPids enumerateObjectsUsingBlock:^(id pid, BOOL *stop) {
        [processes setValue:[NSNumber numberWithInteger:0] forKey:pid];
    }];
}
@end
