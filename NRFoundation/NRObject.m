//
//  NRObject.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "NRObject.h"


@interface NRObjectTrampoline : NSObject
@property (nonatomic, retain) NSMutableArray *deallocBlocks;
- (id)initWithTarget:(id)target;
@end

@implementation NRObjectTrampoline
{
	__unsafe_unretained id _target;
}

@synthesize deallocBlocks = _deallocBlocks;

- (id)initWithTarget:(id)target
{
	self = [super init];
	if (self != nil) {
		_target = target;
		_deallocBlocks = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	for (void (^block)(__unsafe_unretained id object) in _deallocBlocks) {
		block(_target);
	}
}

@end


@interface NRDelayedPerformProxy : NSProxy
- (id)initWithTarget:(id)target;
@end

@implementation NRDelayedPerformProxy
{
	id _target;
}

- (id)initWithTarget:(id)target
{
	NSParameterAssert(target != nil);

	// no init in NSProxy

	_target = target;
	return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [_target methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
	NSParameterAssert([[invocation methodSignature] numberOfArguments] == 2);
	NSAssert(_target != nil, @"NRDelayedPerformProxy: charged proxy twice");
	[_target nr_performSelectorCoalescedOnMainThread:[invocation selector]];
	_target = nil;
}

@end


@implementation NSObject (NRObject)

static const char NRObjectTrampolineAsscociatedObjectKey[] = "NRObjectTrampolineAsscociatedObjectKey";

- (void)nr_performAfterDealloc:(void (^)(__unsafe_unretained id object))block
{
	@synchronized (self) {
		NRObjectTrampoline *objectTrampoline = objc_getAssociatedObject(self, &NRObjectTrampolineAsscociatedObjectKey);

		if (objectTrampoline == nil) {
			objectTrampoline = [[NRObjectTrampoline alloc] initWithTarget:self];
			objc_setAssociatedObject(self, &NRObjectTrampolineAsscociatedObjectKey, objectTrampoline, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}

		[objectTrampoline.deallocBlocks addObject:[block copy]];
	}
}


static void NRSynchronizedAccessToDelayedTargetsSet(void(^block)(CFMutableDictionaryRef *delayedTargetsPtr))
{
	static CFMutableDictionaryRef delayedTargets;

	static dispatch_queue_t delayedTargetQueue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		delayedTargetQueue = dispatch_queue_create("NRDelayedTargetQueue", DISPATCH_QUEUE_SERIAL);
	});

	dispatch_sync(delayedTargetQueue, ^{
		block(&delayedTargets);
	});
}

static void NRDelayedTargetsSetApplierFunction(const void *target, void *selector)
{
	typedef void (* plainMessageSendNoArgs)(const void *target, void *selector);
	((plainMessageSendNoArgs)objc_msgSend)(target, selector);
}

static void NRDelayedTargetsDictionaryApplierFunction(const void *key, const void *value, void *context)
{
	CFSetApplyFunction((CFSetRef)value, NRDelayedTargetsSetApplierFunction, (void *)key);
}

static void NRPerformDelayedSelectors(void)
{
	__block CFDictionaryRef delayedTargetsCopy;

	NRSynchronizedAccessToDelayedTargetsSet(^(CFMutableDictionaryRef *delayedTargetsPtr){
		delayedTargetsCopy = CFDictionaryCreateCopy(kCFAllocatorDefault, *delayedTargetsPtr);
		CFRelease(*delayedTargetsPtr);
		*delayedTargetsPtr = NULL;
	});

	CFDictionaryApplyFunction(delayedTargetsCopy, NRDelayedTargetsDictionaryApplierFunction, NULL);
	CFRelease(delayedTargetsCopy);
}

- (void)nr_performSelectorCoalescedOnMainThread:(SEL)selector
{
	NRSynchronizedAccessToDelayedTargetsSet(^(CFMutableDictionaryRef *delayedTargetsPtr){
		if (*delayedTargetsPtr == NULL) {
			*delayedTargetsPtr = CFDictionaryCreateMutable(kCFAllocatorDefault,
														   0,
														   NULL, // suitable for C strings
														   &kCFTypeDictionaryValueCallBacks);
			dispatch_async(dispatch_get_main_queue(), ^{
				NRPerformDelayedSelectors();
			});
		}

		CFMutableSetRef targets = (CFMutableSetRef)CFDictionaryGetValue(*delayedTargetsPtr, selector);

		if (targets == NULL) {
			CFSetCallBacks setCallbacks = {
				.version         = 0,
				.retain          = kCFTypeSetCallBacks.retain,
				.release         = kCFTypeSetCallBacks.release,
				.copyDescription = NULL,
				.equal           = NULL,
				.hash            = NULL,
			};
			targets = CFSetCreateMutable(kCFAllocatorDefault, 0, &setCallbacks);

			CFDictionarySetValue(*delayedTargetsPtr, selector, targets);
			CFRelease(targets);
		}

		CFSetAddValue(targets, (__bridge void *)self);
	});
}

- (id)nr_performCoalescedOnMainThread
{
	return [[NRDelayedPerformProxy alloc] initWithTarget:self];
}

@end
