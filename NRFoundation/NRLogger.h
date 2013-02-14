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

// If YES redirects write calls to stderr to a file in Library/Logs/AppConsole/
// Filenames follow the pattern "Logfile_2013-02-15".
@property (nonatomic) BOOL redirectStderr;

// If > 0 the number of seconds between automatic logfile rotation checking.
// Defaults to 0.
@property (nonatomic) NSTimeInterval logfileRotationCheckInterval;

// Try to guess if a debugger is attached and reading the output to stderr.
@property (nonatomic, readonly, getter=isDebuggerAttatchedToConsole) BOOL debuggerAttatchedToConsole;

// Check for logfile rotation once.
// This is called automatically if logfileRotationCheckInterval > 0.
- (void)checkLogfileRotation;

// Log basic application info to stderr.
- (void)logAppInfo;

// create a long concatenated file of all log files in the log directory
- (BOOL)writeLogFilesToPath:(NSString *)path;

@end
