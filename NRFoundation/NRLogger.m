//
//  NRLogger.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-02-07.
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#import "NRLogger.h"
#import "NRBundle.h"
#import "NRDevice.h"
#import <unistd.h>


@implementation NRLogger
{
	int _stderrFileDescriptor;
}

+ (instancetype)sharedLogger
{
	static NRLogger *sharedLogger;
	if (sharedLogger == nil)
		sharedLogger = [[self alloc] init];
	return sharedLogger;
}

+ (NSString *)logfileBaseDirectory
{
	static NSString *libraryDirectory;
	if (libraryDirectory == nil) {
		libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
		libraryDirectory = [libraryDirectory stringByAppendingPathComponent:@"Logs"];
		[[NSFileManager defaultManager] createDirectoryAtPath:libraryDirectory
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
	return libraryDirectory;
}

- (id)init
{
	self = [super init];
	if (self) {
		_stderrFileDescriptor = -1;
	}
	return self;
}

- (void)logAppInfo
{
	NSLog(@"Launching: \"%@\" version=\"%@\" bundleIdentifier=\"%@\" UUID=\"%@\"",
		  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
		  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
		  [[NSBundle mainBundle] bundleIdentifier],
		  [NSBundle executableLinkEditorUUID]
		  );

	NSString *deviceName = [UIDevice currentDevice].name;
	NSString *model = [UIDevice currentDevice].model;
	NSString *modelID = [UIDevice currentDevice].modelID;
	NSString *MACAddress = [UIDevice currentDevice].MACAddress;
	NSLog(@"Device: \"%@\" model=\"%@\" modelID=\"%@\" MACAddress=\"%@\"", deviceName, model, modelID, MACAddress);

	NSLog(@"OS: \"%@\" version=\"%@\"", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion);
}

- (BOOL)redirectStderr
{
	return _stderrFileDescriptor >= 0;
}

- (void)setRedirectStderr:(BOOL)redirectStderr
{
	if (self.redirectStderr == (_Bool)redirectStderr)
		return;

	if (redirectStderr) {
		[self startRedirectingStderr];
	} else {
		[self stopRedirectingStderr];
	}
}

- (void)startRedirectingStderr
{
	if (_stderrFileDescriptor >= 0)
		return;

	_stderrFileDescriptor = dup(STDERR_FILENO);
	if (_stderrFileDescriptor < 0) {
		NSLog(@"could not dup stderr: %d", errno);
		return;
	}

	NSString *path = [[self class] logfileBaseDirectory];
	path = [path stringByAppendingPathComponent:@"logfile.txt"];
	const char *logfile = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:path];

	int fd = open(logfile, O_RDWR | O_CREAT | O_TRUNC, 0666);
	if (fd < 0) {
		NSLog(@"could not open logfile: %d", errno);
		close(_stderrFileDescriptor);
		_stderrFileDescriptor = -1;
		return;
	}

	// duplicate the logfile's descriptor over stderr
	int result = dup2(fd, STDERR_FILENO);
	if (result < 0) {
		NSLog(@"could not duplicate logfile descriptor over stderr: %d", errno);
		close(_stderrFileDescriptor);
		_stderrFileDescriptor = -1;
		return;
	}

	// we don't need the original fd of the logfile any more.
	// It's now named stderr
	close(fd);

	// print message to original stderr
	dprintf(_stderrFileDescriptor, "redirecting stderr to \"%s\"\n", logfile);
}

- (void)stopRedirectingStderr
{
	if (_stderrFileDescriptor < 0)
		return;

	int result = dup2(_stderrFileDescriptor, STDERR_FILENO);
	if (result < 0) {
		NSLog(@"could not duplicate original stderr descriptor over stderr: %d", errno);
		return;
	}

	close(_stderrFileDescriptor);
	_stderrFileDescriptor = -1;

	// print message to original stderr
	dprintf(_stderrFileDescriptor, "stopped redirecting stderr\n");
}

@end
