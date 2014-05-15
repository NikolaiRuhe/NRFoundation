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
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@end

@implementation NRTimerTrampoline
@synthesize block = _block;
@synthesize target = _target;
@synthesize selector = _selector;

- (void)fireBlock:(NSTimer *)timer
{
	if (self.block != nil)
		self.block(timer);
}

- (void)fireTarget:(NSTimer *)timer
{
	id strongTarget = self.target;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[strongTarget performSelector:self.selector withObject:timer];
#pragma clang diagnostic pop
}

@end


@implementation NSTimer (NRTimer)

+ (NSTimer *)nr_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval weakTarget:(id)weakTarget selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats
{
	NRTimerTrampoline *trampoline = [[NRTimerTrampoline alloc] init];
	trampoline.target = weakTarget;
	trampoline.selector = selector;
	return [self scheduledTimerWithTimeInterval:timeInterval
										 target:trampoline
									   selector:@selector(fireTarget:)
									   userInfo:userInfo
										repeats:repeats];
}

+ (NSTimer *)nr_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval userInfo:(id)userInfo repeats:(BOOL)repeats block:(NRTimerBlock)block
{
	NRTimerTrampoline *trampoline = [[NRTimerTrampoline alloc] init];
	trampoline.block = block;
	return [self scheduledTimerWithTimeInterval:timeInterval
										 target:trampoline
									   selector:@selector(fireBlock:)
									   userInfo:userInfo
										repeats:repeats];
}

- (id)nr_initWithFireDate:(NSDate *)date interval:(NSTimeInterval)timeInterval weakTarget:(id)weakTarget selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats
{
	NRTimerTrampoline *trampoline = [[NRTimerTrampoline alloc] init];
	trampoline.target = weakTarget;
	trampoline.selector = selector;
	return [self initWithFireDate:date
						 interval:timeInterval
						   target:trampoline
						 selector:@selector(fireTarget:)
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
						 selector:@selector(fireBlock:)
						 userInfo:userInfo
						  repeats:repeats];
}

@end
