//
//  NRMasterViewController.m
//  NRFoundationDemo
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRMasterViewController.h"
#import "NRGestureViewController.h"
#import "NRMemoryLabel.h"
#import <CoreLocation/CoreLocation.h>


@interface NRMasterViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISlider *controlSlider;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@end



@implementation NRMasterViewController
{
	CLLocationManager *_locationManager;
}

@synthesize controlSlider = _controlSlider;
@synthesize distanceLabel = _distanceLabel;

- (void)viewDidLoad
{
	[super viewDidLoad];

	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	[_locationManager startUpdatingLocation];

	[self.controlSlider nr_addAction:^(id sender) {
		UISlider *slider = sender;
		slider.thumbTintColor = [UIColor colorWithHue:((UISlider *)sender).value saturation:1 brightness:1 alpha:1];
	} forControlEvents:UIControlEventValueChanged];

	[NRMemoryLabel setOverlayWindowVisible:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)presentUIActionSheet
{
	[[[UIActionSheet alloc] nr_initWithTitle:@"NRFoundation"
						   cancelButtonTitle:@"Great"
									  action:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
										  [self logMessage:@"--- Great ---"];
									  }
					  destructiveButtonTitle:@"Perfect"
									  action:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
										  [self logMessage:@"--- Perfect ---"];
									  }
							otherButtonTitle:@"OK"
									  action:^(UIActionSheet *actionSheet, NSUInteger buttonIndex) {
										  [self logMessage:@"--- Accepted ---"];
									  }] showInView:self.view];
}

- (void)presentUIGestureRecognizer
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self nr_performSegueWithIdentifier:@"ShowDetailSegue"
								 sender:self
								prepare:^(UIStoryboardSegue *segue) {
									UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
									((NRGestureViewController *)[segue destinationViewController]).title = cell.textLabel.text;
								}];
}

- (void)logMessage:(NSString *)message
{
	CGFloat ypos = 458;
	UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){.size={320, 44}}];
	label.center = (CGPoint){480, ypos};
	label.text = message;
	label.textAlignment = UITextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize:22];
	label.alpha = 0;
	[[[[UIApplication sharedApplication] delegate] window] addSubview:label];
	[UIView animateWithDuration:.75 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		label.center = (CGPoint){160, ypos};
		label.alpha = 1;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:.25 delay:1.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
			label.center = (CGPoint){-160, ypos};
			label.alpha = 0;
		} completion:^(BOOL finished) {
			[label removeFromSuperview];
		}];
	}];
}

- (void)presentUIAlertView
{
	[[[UIAlertView alloc] nr_initWithTitle:@"NRFoundation"
								   message:@"This alert view needs less boilerplate code."
						 cancelButtonTitle:@"Great"
									action:^(UIAlertView *alertView, NSUInteger buttonIndex) {
										[self logMessage:@"--- Great ---"];
									}
						  otherButtonTitle:@"OK"
									action:^(UIAlertView *alertView, NSUInteger buttonIndex) {
										[self logMessage:@"--- Accepted ---"];
									}] show];
}

- (void)presentNSTimer
{
	[self logMessage:@"timer scheduled"];
	__block int count = 1;
	[NSTimer nr_scheduledTimerWithTimeInterval:1 userInfo:nil repeats:YES block:^(NSTimer *timer) {
		if (count == 4) {
			[self logMessage:@"done"];
			[timer invalidate];
			return;
		}
		[self logMessage:[NSString stringWithFormat:@"--- %d ---", count++]];
	}];
}

- (void)presentNRDistanceFormatter
{
	NRDistanceFormatter *formatter = [[NRDistanceFormatter alloc] init];
	CLLocation *umbilicusUrbis = [[CLLocation alloc] initWithLatitude:41.892744 longitude:12.484598];
	CLLocationDistance distance = [_locationManager.location distanceFromLocation:umbilicusUrbis];
	_distanceLabel.text = [NSString stringWithFormat:@"Distance from center: %@", [formatter stringForObjectValue:@(distance)]];
}

static void createTestDirectoryAtPath(NSString *directoryPath, NSInteger fileCount)
{
	[[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
							  withIntermediateDirectories:YES
											   attributes:nil
													error:NULL];
	NSMutableData *data = [NSMutableData data];
	NSData *someBytes = [NSData dataWithBytes:(uint8_t[8]){ 1, 2, 4, 5, 6, 7, 8 } length:8];

	for (NSInteger i = 0; i < fileCount; ++i) {
		NSString *name = [NSString stringWithFormat:@"testfile_%04ld", (long)i];
		NSString *path = [directoryPath stringByAppendingPathComponent:name];
		[data writeToFile:path atomically:NO];
		[data appendData:someBytes];
	}
}

- (unsigned long long)folderSize:(NSString *)folderPath
{
	NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
	NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
	NSString *fileName;
	unsigned long long int fileSize = 0;

	while ((fileName = [filesEnumerator nextObject])) {
		NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
		fileSize += [fileDictionary fileSize];
	}

	return fileSize;
}

- (unsigned long long)allocatedSize:(NSString *)folderPath
{
	unsigned long long allocatedSize;
	[[NSFileManager defaultManager] nr_getAllocatedSize:&allocatedSize
									   ofDirectoryAtURL:[NSURL fileURLWithPath:folderPath]
												  error:NULL];
	return allocatedSize;
}

static long long fileSystemFreeSize(NSString *path)
{
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:NULL];
	return [attributes[NSFileSystemFreeSize] unsignedLongLongValue];
}

- (void)testMethod:(NSString *)testMethod fileCount:(NSInteger)fileCount withBlock:(long long(^)(NSString *folderPath))block
{
	NSLog(@"Test \"%@\"", testMethod);

	NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
	NSString *testDirectory = [cachesDirectory stringByAppendingPathComponent:@"Test"];
	NSLog(@"    preparing %ld test files...", (long)fileCount);

	createTestDirectoryAtPath(testDirectory, fileCount / 2);
	createTestDirectoryAtPath([testDirectory stringByAppendingPathComponent:@"SubDirectory"], fileCount / 2);

	NSLog(@"    test start...");

	CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
	unsigned long long testSize = block(testDirectory);
	CFAbsoluteTime duration = CFAbsoluteTimeGetCurrent() - startTime;

	NSLog(@"    test done");

	NSByteCountFormatter *sizeFormatter = [[NSByteCountFormatter alloc] init];
	sizeFormatter.includesActualByteCount = YES;

	NSLog(@"    size: %@", [sizeFormatter stringFromByteCount:testSize]);
	NSLog(@"    time: %.3f s", duration);

	NSLog(@"    cleaning up...");

	long long availableSizeBefore = fileSystemFreeSize(cachesDirectory);
	[[NSFileManager defaultManager] removeItemAtPath:testDirectory error:NULL];
	long long availableSizeAfter = fileSystemFreeSize(cachesDirectory);

	NSLog(@"    actual bytes removed from file system: %@", [sizeFormatter stringFromByteCount:availableSizeAfter - availableSizeBefore]);
}

- (void)presentNRFileManager
{
	NSInteger fileCount = 1000;

	[self testMethod:@"allocatedSize" fileCount:fileCount withBlock:^long long(NSString *folderPath){
		return [self allocatedSize:folderPath];
	}];

	[self testMethod:@"folderSize" fileCount:fileCount withBlock:^long long(NSString *folderPath){
		return [self folderSize:folderPath];
	}];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[self presentNRDistanceFormatter];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *title = [[tableView cellForRowAtIndexPath:indexPath] textLabel].text;
	SEL selector = NSSelectorFromString([NSString stringWithFormat:@"present%@", title]);
	if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:selector];
#pragma clang diagnostic pop
		[tableView deselectRowAtIndexPath:indexPath	animated:YES];
	}
}

@end
