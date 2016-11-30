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
#import <sys/ioctl.h>
#import <sys/param.h>

#if TARGET_IPHONE_SIMULATOR
	#import <sys/conf.h>
#else
// I don't know why <sys/conf.h> is missing on the iPhoneOS.platform
// It's there on iPhoneSimulator.platform, though. We need it for D_DISK, only:
	#if ! defined(D_DISK)
		#define	D_DISK	2
	#endif
#endif


@implementation NRLogger
{
	int _stderrFileDescriptor;
	NSString *_currentLogFilePath;
	NSTimer *_logfileRotationTimer;
	NSTimeInterval _logfileRotationCheckInterval;
	NSTimer *_memoryLoggingTimer;
	NSTimeInterval _memoryLoggingInterval;
	uint64_t _memoryLoggingResidentSize;
	id <NSObject> _notificationObserver;
}

@synthesize memoryLoggingInterval = _memoryLoggingInterval;
@synthesize excludedNotificationPrefixes = _excludedNotificationPrefixes;

+ (instancetype)sharedLogger
{
	static NRLogger *sharedLogger;
	if (sharedLogger == nil)
		sharedLogger = [[self alloc] init];
	return sharedLogger;
}

- (id)init
{
	self = [super init];
	if (self) {
		_stderrFileDescriptor = -1;
	}
	return self;
}

- (void)dealloc
{
	self.notificationLoggingEnabled = NO;
	self.logfileRotationCheckInterval = 0;
	self.memoryLoggingInterval = 0;
	self.redirectStderr = NO;
}

- (NSString *)logfileDirectory
{
	static NSString *logfileDirectory;
	if (logfileDirectory == nil) {
		logfileDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
		logfileDirectory = [logfileDirectory stringByAppendingPathComponent:@"Logs"];
		logfileDirectory = [logfileDirectory stringByAppendingPathComponent:@"AppConsole"];
		[[NSFileManager defaultManager] createDirectoryAtPath:logfileDirectory
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
	return logfileDirectory;
}

- (NSString *)filenamePrefix
{
	return @"Logfile_";
}

- (NSUInteger)minumNumberOfLogfilesToKeep
{
	// keep a minimum of 3 logfiles before removing any
	return 3;
}

- (NSUInteger)maximumNumberOfLogfilesToKeep
{
	// keep a maximum of 100 logfiles
	return 100;
}

- (unsigned long long)maximumIndividualLogfileSize
{
	// try to keep logfiles under around 1 MB
	return 1024LU * 1024LU * 1LU;
}

- (unsigned long long)maximumCombinedLogfileSize
{
	// keep a maximum of 2 MB
	return 1024LU * 1024LU * 2LU;
}

- (NSTimeInterval)logfileRotationCheckInterval
{
	@synchronized (self) {
		return _logfileRotationCheckInterval;
	}
}

- (void)setLogfileRotationCheckInterval:(NSTimeInterval)logfileRotationCheckInterval
{
	NSAssert([NSThread isMainThread], @"logfileRotationCheckInterval can only be modified from the main thread.");

	@synchronized (self) {

		if (_logfileRotationCheckInterval == logfileRotationCheckInterval)
			return;

		_logfileRotationCheckInterval = logfileRotationCheckInterval;

		if (_logfileRotationCheckInterval <= 0) {
			_logfileRotationCheckInterval = 0;
			[_logfileRotationTimer invalidate];
			_logfileRotationTimer = nil;
			return;
		}

		[_logfileRotationTimer invalidate];
		_logfileRotationTimer = [NSTimer scheduledTimerWithTimeInterval:_logfileRotationCheckInterval
																 target:self
															   selector:@selector(logfileRotationTimerFired:)
															   userInfo:nil
																repeats:YES];
		_logfileRotationTimer.tolerance = _logfileRotationCheckInterval / 3.0;
	}
}

- (void)logfileRotationTimerFired:(NSTimer *)timer
{
	[self checkLogfileRotation];
}

- (NSString *)contents
{
	NSData *data = [NSData dataWithContentsOfFile:_currentLogFilePath];
	if (data == nil)
		return @"";
	NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return contents ?: @"";
}

- (NSArray *)logFileURLsSortNewestFirst:(BOOL)newestFirst notOlderThan:(NSDate *)dateThreshold
{
	NSString *directory = [self logfileDirectory];
	NSArray *fileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:directory isDirectory:YES]
													  includingPropertiesForKeys:@[NSURLIsRegularFileKey, NSURLFileSizeKey, NSURLContentModificationDateKey]
																		 options:NSDirectoryEnumerationSkipsHiddenFiles
																		   error:NULL];

	// filter proper logfiles
	NSMutableArray *files = [NSMutableArray array];
	for (NSURL *fileURL in fileURLs) {
		if (! [[fileURL lastPathComponent] hasPrefix:[self filenamePrefix]])
			continue;
		NSNumber *isFile;
		if (! [fileURL getResourceValue:&isFile forKey:NSURLIsRegularFileKey error:NULL])
			continue;
		if (! [isFile boolValue])
			continue;

		if (dateThreshold != nil) {
			NSDate *date;
			if (! [fileURL getResourceValue:&date forKey:NSURLContentModificationDateKey error:NULL])
				continue;
			if ([date compare:dateThreshold] == NSOrderedAscending)
				continue;
		}
		[files addObject:fileURL];
	}

	// sort files by modification date
	[files sortUsingComparator:^NSComparisonResult(NSURL *file1, NSURL *file2) {
		NSDate *date1;
		[file1 getResourceValue:&date1
						 forKey:NSURLContentModificationDateKey
						  error:NULL];
		NSDate *date2;
		[file2 getResourceValue:&date2
						 forKey:NSURLContentModificationDateKey
						  error:NULL];
		return newestFirst ? [date2 compare:date1] : [date1 compare:date2];
	}];

	return files;
}

- (unsigned long long)removeOldLogfiles
{
	unsigned long long combinedSize = 0;
	NSUInteger logfileCount = 0;

	// iterate over existing logfiles, newest first
	NSArray *fileURLs = [self logFileURLsSortNewestFirst:YES notOlderThan:nil];
	for (NSURL *fileURL in fileURLs) {

		logfileCount += 1;

		BOOL canRemoveLogfiles    = logfileCount > [self minumNumberOfLogfilesToKeep];
		BOOL shouldRemoveLogfiles = combinedSize > [self maximumCombinedLogfileSize];
		BOOL mustRemoveLogfiles   = logfileCount > [self maximumNumberOfLogfilesToKeep];

		if ((canRemoveLogfiles && shouldRemoveLogfiles) || mustRemoveLogfiles) {
			NSLog(@"removing old logfile: %@", [fileURL lastPathComponent]);
			[[NSFileManager defaultManager] removeItemAtURL:fileURL
													  error:NULL];
		} else {
			NSNumber *fileSize;
			[fileURL getResourceValue:&fileSize
							   forKey:NSURLFileSizeKey
								error:NULL];

			combinedSize += [fileSize unsignedLongLongValue];
		}
	}

	return combinedSize;
}

- (NSString *)newLogFilename
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
	[formatter setLocale:nil];

	NSString *filename = [NSString stringWithFormat:@"%@%@.log", [self filenamePrefix], [formatter stringFromDate:[NSDate date]]];

	NSString *path = [[self logfileDirectory] stringByAppendingPathComponent:filename];

	return path;
}

- (void)checkLogfileRotation
{
	@synchronized (self) {

		// do we redirect at the moment?
		if (! self.redirectStderr)
			return;

		// STDERR_FILENO is the file descriptor of our logfile
		off_t offset = lseek(STDERR_FILENO, 0, SEEK_CUR);
		if (offset < 0)
			return;

		if (offset < (off_t)[self maximumIndividualLogfileSize])
			return;

		// create new logfile and remove old files
		[self redirectStderrIntoNewLogfile];
	}
}

- (void)logAppInfo
{
	NSString* documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:documentsPath error:NULL];
	unsigned long long freeDiskBytes = [attributes[NSFileSystemFreeSize] unsignedLongLongValue];

	NSUInteger wired;
	NSUInteger active;
	NSUInteger inactive;
	NSUInteger freeBytes;
	NSUInteger physicalMemory;
	[[UIDevice currentDevice] getMemorySizesForWired:&wired active:&active inactive:&inactive free:&freeBytes physicalMemory:&physicalMemory];
	unsigned long availableMemoryBytes = inactive + freeBytes;
	unsigned long totalMemoryBytes = wired + active + availableMemoryBytes;

	NSLog(@"\n"
		  @"name=\"%@\"\n"
		  @"version=\"%@\"\n"
		  @"bundleIdentifier=\"%@\"\n"
		  @"LC_UUID=\"%@\"\n"
		  @"path=\"%@\"\n"
		  @"documentsPath=\"%@\"\n"
		  @"freeDiskBytes=\"%.1f GB\"\n"
		  @"physicalMemory=\"%.1f MB\"\n"
		  @"totalMemory=\"%.1f MB\"\n"
		  @"availableMemory=\"%.1f MB\"\n"
		  @"residentSize=\"%.1f MB\"\n"
		  @"device=\"%@\"\n"
		  @"model=\"%@\"\n"
		  @"modelID=\"%@\"\n"
		  @"uniqueIdentifier=\"%@\"\n"
		  @"OS=\"%@ %@\"\n"
		  @"locale=\"%@\"\n"
		  @"preferredLocalizations=\"%@\"\n"
		  @"timezone=\"%@: %+ld\"\n\n",
		  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
		  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
		  [[NSBundle mainBundle] bundleIdentifier],
		  [NSBundle executableLinkEditorUUID],
		  [[NSBundle mainBundle] executablePath],
		  documentsPath,
		  freeDiskBytes        / (double)(1024 * 1024 * 1024),
		  physicalMemory       / (double)(1024 * 1024),
		  totalMemoryBytes     / (double)(1024 * 1024),
		  availableMemoryBytes / (double)(1024 * 1024),
		  [[UIDevice currentDevice] nr_residentSize] / (double)(1024 * 1024),
		  [UIDevice currentDevice].name,
		  [UIDevice currentDevice].model,
		  [UIDevice currentDevice].modelID,
		  [[UIDevice currentDevice] nr_uniqueIdentifier],
		  [UIDevice currentDevice].systemName,
		  [UIDevice currentDevice].systemVersion,
		  [[NSLocale currentLocale] localeIdentifier],
		  [[[NSBundle mainBundle] preferredLocalizations] componentsJoinedByString:@", "],
		  [[[NSCalendar currentCalendar] timeZone] name], (long)([[[NSCalendar currentCalendar] timeZone] secondsFromGMT] / 60)
	);
}

- (BOOL)redirectStderr
{
	@synchronized (self) {
		return _stderrFileDescriptor >= 0;
	}
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
	@synchronized (self) {

		if (self.redirectStderr)
			return;

		// make a copy of stderr
		_stderrFileDescriptor = dup(STDERR_FILENO);
		if (_stderrFileDescriptor < 0) {
			NSLog(@"could not dup stderr: %d", errno);
			return;
		}

		if (! [self redirectStderrIntoNewLogfile]) {
			close(_stderrFileDescriptor);
			_stderrFileDescriptor = -1;
		}
		//asl_add_log_file
	}
}

- (BOOL)redirectStderrIntoNewLogfile
{
	@synchronized (self) {

		NSString *path = [self newLogFilename];

		const char *logfilename = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:path];

		int fd = open(logfilename, O_RDWR | O_CREAT | O_TRUNC, 0666);
		if (fd < 0) {
			NSLog(@"could not open logfile: %d", errno);
			return NO;
		}

		// duplicate the logfile's descriptor over stderr
		int result = dup2(fd, STDERR_FILENO);
		if (result < 0) {
			NSLog(@"could not duplicate logfile descriptor over stderr: %d", errno);
			close(fd);
			return NO;
		}

		// we don't need the original fd of the logfile any more.
		// It's now named stderr
		close(fd);

		// print message to original stderr
		dprintf(_stderrFileDescriptor, "redirecting stderr to \"%s\"\n", logfilename);

		dprintf(STDERR_FILENO,
				"--------------------------------------------------------------------------------\n"
				"%s\n"
				"--------------------------------------------------------------------------------\n",
				logfilename);

		[self removeOldLogfiles];

		_currentLogFilePath = path;
		return YES;
	}
}

- (void)stopRedirectingStderr
{
	@synchronized (self) {

		if (! self.redirectStderr)
			return;

		int result = dup2(_stderrFileDescriptor, STDERR_FILENO);
		if (result < 0) {
			NSLog(@"could not duplicate original stderr descriptor over stderr: %d", errno);
			return;
		}

		close(_stderrFileDescriptor);
		_stderrFileDescriptor = -1;
		_currentLogFilePath = nil;

		// print message to original stderr
		dprintf(STDERR_FILENO, "stopped redirecting stderr\n");
	}
}

- (BOOL)writeLogFilesToPath:(NSString *)path
{
	if (! [[NSFileManager defaultManager] createFileAtPath:path contents:[NSData data] attributes:nil]) {
		NSLog(@"could not create archive at path: %@", path);
		return NO;
	}

	NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:path];
	if (outFile == nil) {
		NSLog(@"could not create file handle for writing at path: %@", path);
		return NO;
	}
	[self enumerateLogContentsAfterDate:nil
					   maximumFileCount:0
						  maximumLength:0
							  withBlock:^(NSURL *fileURL, NSData *contents) {
								  [outFile writeData:contents];
								  char message[] = "\n--- end of file ---\n\n";
								  [outFile writeData:[NSData dataWithBytes:message length:sizeof(message) - 1]];
							  }];
	return YES;
}

- (void)enumerateLogContentsAfterDate:(NSDate *)dateThreshold maximumFileCount:(NSInteger)maximumFileCount maximumLength:(unsigned long long)maximumSize withBlock:(void(^)(NSURL *fileURL, NSData *contents))block
{
	NSArray *logFiles = [self logFileURLsSortNewestFirst:YES notOlderThan:dateThreshold];

	// skip files to meet the maximumFileCount constraint if necessary
	if (maximumFileCount != 0 && (NSInteger)logFiles.count > maximumFileCount)
		logFiles = [logFiles subarrayWithRange:(NSRange){ 0, maximumFileCount }];

	// skip files that overflow the maximumLength constraint if necessary
	unsigned long long accumulatedSize = 0;
	if (maximumSize != 0) {
		NSMutableArray *filteredLogFiles = [NSMutableArray array];
		for (NSURL *fileURL in logFiles) {
			[filteredLogFiles addObject:fileURL];
			NSNumber *fileSize;
			if (! [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL])
				continue;
			accumulatedSize += fileSize.unsignedLongLongValue;
			if (accumulatedSize >= maximumSize)
				break;
		}
		logFiles = filteredLogFiles;
	}

	for (NSURL *fileURL in logFiles.reverseObjectEnumerator) {
		@autoreleasepool {
			NSData *inData = [NSData dataWithContentsOfURL:fileURL
												   options:NSDataReadingMappedIfSafe
													 error:NULL];
			if (inData == nil)
				continue;

			if (maximumSize != 0 && maximumSize < accumulatedSize) {
				// we have to skip bytes to match the maximum length constraint
				unsigned long long overflowBytes = accumulatedSize - maximumSize;
				unsigned long long fileBytes = inData.length;
				if (overflowBytes >= fileBytes) {
					accumulatedSize -= fileBytes;
					continue;
				}
				inData = [inData subdataWithRange:(NSRange){ (NSInteger)overflowBytes, (NSInteger)(fileBytes - overflowBytes)}];
				accumulatedSize = maximumSize;
			}

			if ([inData length] != 0)
				block(fileURL, inData);
		}
	}
}

- (BOOL)isDebuggerAttatchedToConsole
{
	// We use the type of the original stderr file descriptor
	// to guess if a debugger is attached.

	int fd = self.redirectStderr ? _stderrFileDescriptor : STDERR_FILENO;

	// is the file handle open?
	if (fcntl(fd, F_GETFD, 0) < 0) {
		return NO;
	}

	// get the path of stderr's file handle
	char buf[MAXPATHLEN + 1];
	if (fcntl(fd, F_GETPATH, buf ) >= 0) {
		if (strcmp(buf, "/dev/null") == 0)
			return NO;
		if (strncmp(buf, "/dev/tty", 8) == 0)
			return YES;
	}

	// On the device, without attached Xcode, the type is D_DISK (otherwise it's D_TTY)
	int type;
	if (ioctl(fd, FIODTYPE, &type) < 0) {
		return NO;
	}

	return type != D_DISK;
}

- (void)setMemoryLoggingInterval:(NSTimeInterval)memoryLoggingInterval
{
	NSAssert([NSThread isMainThread], @"memoryLoggingInterval can only be modified from the main thread.");

	if (_memoryLoggingInterval == memoryLoggingInterval)
		return;

	_memoryLoggingInterval = memoryLoggingInterval;

	[_memoryLoggingTimer invalidate];
	_memoryLoggingTimer = nil;

	if (_memoryLoggingInterval <= 0) {
		_memoryLoggingInterval = 0;
	} else {
		_memoryLoggingTimer = [NSTimer scheduledTimerWithTimeInterval:_memoryLoggingInterval
															   target:self
															 selector:@selector(memoryLoggingTimerFired:)
															 userInfo:nil
															  repeats:YES];
		_memoryLoggingTimer.tolerance = _memoryLoggingInterval / 3.0;
		[self memoryLoggingTimerFired:nil];
	}
}

static const double kMemoryLoggingThreshold = 0.05;

- (void)memoryLoggingTimerFired:(NSTimer *)timer
{
	uint64_t residentSize = [[UIDevice currentDevice] nr_residentSize];
	double change = fabs(((int64_t)residentSize - (int64_t)_memoryLoggingResidentSize) / (double)_memoryLoggingResidentSize);

	if (_memoryLoggingResidentSize != 0 && change < kMemoryLoggingThreshold)
		return;

	[self logResidentSize:residentSize];
}

- (void)logResidentSize
{
	[self logResidentSize:[[UIDevice currentDevice] nr_residentSize]];
}

- (void)logResidentSize:(uint64_t)residentSize
{
	_memoryLoggingResidentSize = residentSize;
	NSLog(@"resident size: %.1f MB", _memoryLoggingResidentSize / (1024.0 * 1024.0));
}

- (BOOL)notificationLoggingEnabled
{
	return _notificationObserver != nil;
}

- (void)setNotificationLoggingEnabled:(BOOL)notificationLoggingEnabled
{
	notificationLoggingEnabled = (_Bool)notificationLoggingEnabled;
	if (self.notificationLoggingEnabled == notificationLoggingEnabled)
		return;

	if (_notificationObserver == nil) {
		_notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:nil
																				  object:nil
																				   queue:nil
																			  usingBlock:^(NSNotification *notification) {
																				  if ([self.excludedNotificationPrefixes member:[notification name]] == nil)
																					  NSLog(@"notification: %@", notification.name);
																			  }];
	} else {
		[[NSNotificationCenter defaultCenter] removeObserver:_notificationObserver];
		_notificationObserver = nil;
	}
}


@end


#if defined(NR_LOGGER_AUTOSTART) && NR_LOGGER_AUTOSTART
static void autostart(void) __attribute__((constructor));
static void autostart(void)
{
	if ([NRLogger sharedLogger].debuggerAttatchedToConsole) {
		[NRLogger sharedLogger].redirectStderr = YES;
	}

	[[NRLogger sharedLogger] logAppInfo];
}
#endif
