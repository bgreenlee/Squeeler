//
//  SQProcessTracker.m
//  Squeeler
//
//  Created by Brad Greenlee on 2/21/14.
//  Copyright (c) 2014 HackArts. All rights reserved.
//

#import "SQProcessTracker.h"
#import <sys/proc_info.h>
#import <libproc.h>


@implementation SQProcessTracker
@synthesize delegate;

- (id)init {
    if ((self = [super init])) {
        processes = [[NSMutableDictionary alloc] init];
        alertedProcesses = [[NSMutableDictionary alloc] init];
        // load settings
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.cpuUsageThreshold = [defaults integerForKey:@"cpuUsage"];
        if (self.cpuUsageThreshold == 0) {
            self.cpuUsageThreshold = DEFAULT_CPU_USAGE;
        }
        self.alertTime = [defaults integerForKey:@"alertTime"];
        if (self.alertTime == 0) {
            self.alertTime = DEFAULT_ALERT_TIME;
        }
        self.alertReset = [defaults integerForKey:@"alertReset"];
        if (self.alertReset == 0) {
            self.alertReset = DEFAULT_ALERT_RESET;
        }
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

/*
 * getProcessName returns a the name of a process given a pid
 * It seems like the only way to get the full process name is to
 * extract it from the executable path.
 */
- (NSString *) processNameForPid:(pid_t) pid {
    NSString *processName;
    char pathBuffer[PROC_PIDPATHINFO_MAXSIZE];
    bzero(pathBuffer, PROC_PIDPATHINFO_MAXSIZE);
    proc_pidpath(pid, pathBuffer, sizeof(pathBuffer));
    if (strlen(pathBuffer) > 0) {
        // get last component of path
        char *lastSlash = strrchr(pathBuffer, '/');
        char *processNamePtr;
        if (lastSlash != NULL) {
            processNamePtr = lastSlash + 1;
        } else {
            processNamePtr = pathBuffer;
        }
        processName = [NSString stringWithCString:processNamePtr encoding:NSASCIIStringEncoding];
        NSLog(@"proccessName: %@", processName);
    } else {
        NSLog(@"no pathBuffer!");
        processName = [NSString stringWithFormat:@"Process #%d", pid];
    }
    
    return processName;
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
    [processes enumerateKeysAndObjectsUsingBlock:^(id pidStr, id counter, BOOL *stop) {
        NSNumber *lastCPU = [lastProcessStatus objectForKey:pidStr];
        if (lastCPU == nil) {
            [processes removeObjectForKey:pidStr]; // not in the latest process update, so remove it
        } else {
            NSInteger intCounter = [(NSNumber *)counter integerValue];
            if ([lastCPU integerValue] > self.cpuUsageThreshold) {
                if (intCounter >= self.alertTime / CHECK_INTERVAL) {
                    // check that we haven't alerted on this process recently
                    NSDate *lastAlert = [alertedProcesses objectForKey:pidStr];
                    if (lastAlert == nil || [lastAlert timeIntervalSinceNow] < -self.alertReset) {
                        [alertedProcesses setObject:[NSDate date] forKey:pidStr];
                        pid_t pid = [pidStr intValue];
                        [delegate handleProcessAlertWithPid:pid processName:[self processNameForPid:pid]];  // send notification
                    }
                    [processes setValue:[NSNumber numberWithInteger:0] forKey:pidStr]; // reset so we're not continually spamming
                } else {
                    NSLog(@"Bumping counter for %@ up to %li", pidStr, intCounter + 1);
                    [processes setValue:[NSNumber numberWithInteger:intCounter + 1] forKey:pidStr];
                }
            } else if (intCounter > 0) {
                NSLog(@"Decrementing counter for %@ down to %li", pidStr, intCounter - 1);
                [processes setValue:[NSNumber numberWithInteger:intCounter - 1] forKey:pidStr];
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
