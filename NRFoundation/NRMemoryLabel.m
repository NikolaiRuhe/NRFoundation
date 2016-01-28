//
//  NRMemoryLabel.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2014-08-14
//  Copyright (c) 2014 Nikolai Ruhe. All rights reserved.
//

#import "NRMemoryLabel.h"
#import "NRNotificationCenter.h"
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
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:.7];
	self.textColor       = [UIColor whiteColor];
	self.textAlignment   = NSTextAlignmentCenter;
	self.lineBreakMode   = NSLineBreakByClipping;
	self.font            = [UIFont systemFontOfSize:12];
	self.updateInterval  = 1;
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
	preferredSize.width = ceilCG(preferredSize.width);
	preferredSize.height = ceilCG(preferredSize.height);

	return preferredSize;
}

static UIWindow *overlayWindow;

+ (BOOL)overlayWindowVisible
{
	return overlayWindow != nil;
}

+ (void)setOverlayWindowVisible:(BOOL)overlayWindowVisible
{
	if (! overlayWindowVisible) {
		if (overlayWindow != nil) {
			overlayWindow.hidden = YES;
			overlayWindow = nil;
		}
		return;
	}

	if (overlayWindow != nil)
		return;

	UIScreen *screen = [UIScreen mainScreen];
	CGRect frame = [UIScreen mainScreen].bounds;

	if ([screen respondsToSelector:NSSelectorFromString(@"fixedCoordinateSpace")]) {
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
		frame = [screen.coordinateSpace convertRect:frame toCoordinateSpace:screen.fixedCoordinateSpace];
#endif
	}

	NRMemoryLabel *memoryLabel = [[self alloc] init];
	[memoryLabel sizeToFit];
	CGRect bounds = memoryLabel.bounds;

	bounds.origin = frame.origin;
	bounds.origin.x += roundCG((CGFloat)0.5 * (frame.size.width - bounds.size.width));
	bounds.origin.y += frame.size.height - bounds.size.height;

	overlayWindow = [[UIWindow alloc] initWithFrame:bounds];
	overlayWindow.windowLevel = 10000;
	overlayWindow.userInteractionEnabled = NO;

	memoryLabel.frame = (CGRect) { .size = bounds.size };
	[overlayWindow addSubview:memoryLabel];

	overlayWindow.hidden = NO;

	[[NSNotificationCenter defaultCenter] nr_addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
														 object:nil
														  owner:overlayWindow
													 usingBlock:^(id owner, NSNotification *notification) {
														 [self flashMemoryWarningIndicator];
													 }];
}

+ (void)flashMemoryWarningIndicator
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

@end
