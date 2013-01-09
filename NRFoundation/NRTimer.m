//
//  NRTimer.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-09-04.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRTimer.h"

@interface NRTimerTrampoline : NSObject
@property (nonatomic, copy) NRTimerBlock block;
@end

@implementation NRTimerTrampoline
@synthesize block = _block;

- (void)fire:(NSTimer *)timer
{
	self.block(timer);
}

@end


@implementation NSTimer (NRTimer)

+ (NSTimer *)nr_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval userInfo:(id)userInfo repeats:(BOOL)repeats block:(NRTimerBlock)block
{
	NRTimerTrampoline *trampoline = [[NRTimerTrampoline alloc] init];
	trampoline.block = block;
	return [self scheduledTimerWithTimeInterval:timeInterval
										 target:trampoline
									   selector:@selector(fire:)
									   userInfo:userInfo
										repeats:repeats];
}

- (id)nr_initWithFireDate:(NSDate *)date interval:(NSTimeInterval)timeInterval userInfo:(id)userInfo repeats:(BOOL)repeats block:(NRTimerBlock)block
{
	NRTimerTrampoline *trampoline = [[NRTimerTrampoline alloc] init];
	trampoline.block = block;
	return [self initWithFireDate:date
						 interval:timeInterval
						   target:trampoline
						 selector:@selector(fire:)
						 userInfo:userInfo
						  repeats:repeats];
}

@end
