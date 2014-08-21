//
//  NRLogger.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-02-07.
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NRLogger : NSObject

+ (instancetype)sharedLogger;

//             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#pragma mark - ┃ Log output                                                                        ┃
//             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

// If YES redirects write calls to stderr to a file in Library/Logs/AppConsole/
// Filenames follow the pattern "Logfile_2013-02-15".
@property (nonatomic) BOOL redirectStderr;

//             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#pragma mark - ┃ Application state logging                                                         ┃
//             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

// Log basic application info to stderr.
- (void)logAppInfo;

//             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#pragma mark - ┃ Memory logging                                                                    ┃
//             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

// Print the amount of used resident memory.
- (void)logResidentSize;

// The memoryLogging feature periodically checks the amount of resident memory
// used by the app and prints a log message if the value changed considerably
// (more than 5%). To enable the feature set the memoryLoggingInterval property
// to an amount greter than zero. Default is zero.
@property (nonatomic) NSTimeInterval memoryLoggingInterval;

//             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#pragma mark - ┃ Notification logging                                                              ┃
//             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

@property (nonatomic) BOOL notificationLoggingEnabled;
@property (nonatomic, copy) NSSet *excludedNotificationPrefixes;

//             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#pragma mark - ┃ Log file handling                                                                 ┃
//             ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

// If > 0 the number of seconds between automatic logfile rotation checking.
// Defaults to 0.
@property (nonatomic) NSTimeInterval logfileRotationCheckInterval;

// Try to guess if a debugger is attached and reading the output to stderr.
@property (nonatomic, readonly, getter=isDebuggerAttatchedToConsole) BOOL debuggerAttatchedToConsole;

// Check for logfile rotation once.
// This is called automatically if logfileRotationCheckInterval > 0.
- (void)checkLogfileRotation;

// create a long concatenated file of all log files in the log directory
- (BOOL)writeLogFilesToPath:(NSString *)path;

// Scan the log file directory for old log files and return them sorted by modification date.
- (NSArray *)logFileURLsOrderedByModificationDate;

@end
