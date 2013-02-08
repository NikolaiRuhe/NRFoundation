//
//  NRNotificationCenter.m
//  NRFoundation
//
//  Created by nikolai on 08.02.13.
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#import "NRNotificationCenter.h"
#import <objc/runtime.h>


static NSString *NRNotificationCenterObserverKey = @"NRNotificationCenterObserverKey";

@interface NRObserverTrampoline : NSObject
@end

@implementation NRObserverTrampoline
{
	__weak id _observer;
	SEL _selector;
	void(^_block)(id observer, NSNotification *notification);
	void(^_noOwnerBlock)(NSNotification *notification);
}

- (id)initWithObserver:(id)observer selector:(SEL)selector
{
	self = [self init];
	if (self != nil) {
		_observer = observer;
		_selector = selector;
	}
	return self;
}

- (id)initWithObserver:(id)observer block:(void(^)(id observer, NSNotification *notification))block
{
	self = [self init];
	if (self != nil) {
		_observer = observer;
		_block = [block copy];
	}
	return self;
}

- (id)initWithBlock:(void(^)(NSNotification *notification))block
{
	self = [self init];
	if (self != nil) {
		_noOwnerBlock = [block copy];
	}
	return self;
}

- (id)observer
{
	return _observer;
}

- (void)forwardNotification:(NSNotification *)notification
{
	if (_noOwnerBlock != NULL)
		_noOwnerBlock(notification);

	id strongObserver = _observer;

	if (_block != NULL)
		_block(strongObserver, notification);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[strongObserver performSelector:_selector withObject:notification];
#pragma clang diagnostic pop
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation NSNotificationCenter (NRNotificationCenter)

- (NRObserverID)nr_addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object
{
	NRObserverTrampoline *trampoline = [[NRObserverTrampoline alloc] initWithObserver:observer selector:selector];
	[self nr_addObserverTrampoline:trampoline owner:observer name:name object:object];
	return trampoline;
}

- (NRObserverID)nr_addObserver:(id)observer name:(NSString *)name object:(id)object usingBlock:(void (^)(id observer, NSNotification *notification))block
{
	NRObserverTrampoline *trampoline = [[NRObserverTrampoline alloc] initWithObserver:observer block:block];
	[self nr_addObserverTrampoline:trampoline owner:observer name:name object:object];
	return trampoline;
}

- (NRObserverID)nr_addObserverForName:(NSString *)name object:(id)object usingBlock:(void (^)(NSNotification *notification))block
{
	NRObserverTrampoline *trampoline = [[NRObserverTrampoline alloc] initWithBlock:block];
	[self nr_addObserverTrampoline:trampoline owner:nil name:name object:object];
	return trampoline;
}

- (void)nr_addObserverTrampoline:(NRObserverTrampoline *)trampoline owner:(id)owner name:(NSString *)name object:(id)object
{
	if (owner != nil) {
		NSMutableArray *trampolines = objc_getAssociatedObject(owner, &NRNotificationCenterObserverKey);
		if (trampolines == nil) {
			trampolines = [NSMutableArray array];
			objc_setAssociatedObject(owner, &NRNotificationCenterObserverKey, trampolines, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
		[trampolines addObject:trampoline];
	}

	[self addObserver:trampoline
			 selector:@selector(forwardNotification:)
				 name:name
			   object:object];
}

- (void)nr_removeObserver:(NRObserverID)observerID
{
	NRObserverTrampoline *trampoline = observerID;
	id observer = [trampoline observer];
	if (observer != nil) {
		NSMutableArray *trampolines = objc_getAssociatedObject(observer, &NRNotificationCenterObserverKey);
		[trampolines removeObjectIdenticalTo:trampoline];
	}
	[self removeObserver:observerID];
}

@end
