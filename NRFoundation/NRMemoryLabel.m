//
//  NRMemoryLabel.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2014-08-14
//  Copyright (c) 2014 Nikolai Ruhe. All rights reserved.
//

#import "NRMemoryLabel.h"
#import "NRTimer.h"
#import "NRDevice.h"

@implementation NRMemoryLabel
{
	NSTimer *_updateTimer;
}

@synthesize updateInterval = _updateInterval;
@synthesize residentSize   = _residentSize;

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self != nil)
		setup(self);
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil)
		setup(self);
	return self;
}

static void setup(NRMemoryLabel *self)
{
	self.backgroundColor = [UIColor blackColor];
	self.textColor       = [UIColor whiteColor];
	self.textAlignment   = NSTextAlignmentRight;
	self.lineBreakMode   = NSLineBreakByClipping;
	self.font            = [UIFont systemFontOfSize:12];
	self.updateInterval  = 1;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationDidReceiveMemoryWarning:)
												 name:UIApplicationDidReceiveMemoryWarningNotification
											   object:nil];
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification
{
	CGRect frame = [UIScreen mainScreen].bounds;
	frame = CGRectInset(frame, 20, 20);

	UIWindow *window = [[UIWindow alloc] initWithFrame:frame];
	window.windowLevel = 20000;
	window.hidden = NO;
	window.backgroundColor = [UIColor colorWithRed:.8 green:0 blue:0 alpha:.8];

	UILabel *label = [[UILabel alloc] initWithFrame:window.bounds];
	label.text = @"Memory Warning";
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont boldSystemFontOfSize:32];
	label.textAlignment = NSTextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = YES;
	[window addSubview:label];
	window.userInteractionEnabled = NO;

	[UIView animateWithDuration:.25
						  delay:1
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 window.alpha = 0;
					 } completion:^(BOOL finished) {
						 window.hidden = YES;
					 }];
}

- (void)setUpdateInterval:(NSTimeInterval)updateInterval
{
	_updateInterval = updateInterval;

	[_updateTimer invalidate];
	_updateTimer = nil;

	if (_updateInterval <= 0)
		return;

	_updateTimer = [NSTimer nr_scheduledTimerWithTimeInterval:_updateInterval
												   weakTarget:self
													 selector:@selector(updateMemory:)
													 userInfo:nil
													  repeats:YES];
	[self updateMemory:nil];
}

- (void)updateMemory:(NSTimer *)timer
{
	uint64_t residentSize = [[UIDevice currentDevice] nr_residentSize];
	self.text = [NSString stringWithFormat:@"%6.1f MB", residentSize / (1024.0 * 1024.0)];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	CGSize preferredSize = [@"0000.0 MB" boundingRectWithSize:(CGSize){ CGFLOAT_MAX, CGFLOAT_MAX }
													  options:NSStringDrawingUsesLineFragmentOrigin
												   attributes:@{ NSFontAttributeName : self.font }
													  context:nil].size;
	preferredSize.width = ceil(preferredSize.width);
	preferredSize.height = ceil(preferredSize.height);

	return preferredSize;
}

- (void)presentInOverlayWindow
{
	CGRect frame = [UIScreen mainScreen].bounds;

	[self sizeToFit];
	CGRect bounds = self.bounds;

	bounds.origin = frame.origin;
	bounds.origin.x += round(0.5 * (frame.size.width - bounds.size.width));
	bounds.origin.y += frame.size.height - bounds.size.height;

	static UIWindow *window;

	window = [[UIWindow alloc] initWithFrame:bounds];
	window.windowLevel = 10000;
	window.userInteractionEnabled = NO;

	UIViewController *viewController = [[UIViewController alloc] init];
	viewController.view.backgroundColor = [UIColor clearColor];
	viewController.view.opaque = NO;
	window.rootViewController = viewController;

	self.frame = (CGRect) { .size = bounds.size };
	[window addSubview:self];

	window.hidden = NO;
}

@end
