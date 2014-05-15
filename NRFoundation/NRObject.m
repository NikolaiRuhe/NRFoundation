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
	[_target nr_performSelectorDelayedOnMainThread:[invocation selector]];
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

- (NRKVObserverID)nr_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void(^)(id observee, id observer))block
{
	// TODO: implement
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

- (NRKVObserverID)nr_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void(^)(id observee))block
{
	// TODO: implement
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

+ (void)nr_removeObservance:(NRKVObserverID)KVObserverID
{
	// TODO: implement
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}


static CFMutableDictionaryRef _delayedTargets;

static void NRPerformOnDelayedTargetsQueue(void(^block)())
{
	static dispatch_queue_t delayedTargetQueue;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		delayedTargetQueue = dispatch_queue_create("NRDelayedTargetQueue", DISPATCH_QUEUE_SERIAL);
	});

	dispatch_sync(delayedTargetQueue, block);
}

static void NRDelayedTargetsSetApplierFunction(const void *target, void *selector)
{
	objc_msgSend((__bridge id)target, selector);
}

static void NRDelayedTargetsDictionaryApplierFunction(const void *key, const void *value, void *context)
{
	CFSetApplyFunction((CFSetRef)value, NRDelayedTargetsSetApplierFunction, (void *)key);
}

static void NRPerformDelayedSelectors(void)
{
	__block CFDictionaryRef delayedTargets;

	NRPerformOnDelayedTargetsQueue(^{
		delayedTargets = CFDictionaryCreateCopy(kCFAllocatorDefault, _delayedTargets);
		CFRelease(_delayedTargets);
		_delayedTargets = NULL;
	});

	CFDictionaryApplyFunction(delayedTargets, NRDelayedTargetsDictionaryApplierFunction, NULL);
	CFRelease(delayedTargets);
}

- (void)nr_performSelectorDelayedOnMainThread:(SEL)selector
{
	NRPerformOnDelayedTargetsQueue(^{
		if (_delayedTargets == NULL) {
			_delayedTargets = CFDictionaryCreateMutable(kCFAllocatorDefault,
														0,
														NULL, // suitable for C strings
														&kCFTypeDictionaryValueCallBacks);
			dispatch_async(dispatch_get_main_queue(), ^{
				NRPerformDelayedSelectors();
			});
		}

		CFMutableSetRef targets = (CFMutableSetRef)CFDictionaryGetValue(_delayedTargets, selector);

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

			CFDictionarySetValue(_delayedTargets, selector, targets);
			CFRelease(targets);
		}

		CFSetAddValue(targets, (__bridge void *)self);
	});
}

- (id)nr_performDelayedOnMainThread
{
	return [[NRDelayedPerformProxy alloc] initWithTarget:self];
}

@end
