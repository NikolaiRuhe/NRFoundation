//
//  NRObject.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <objc/runtime.h>
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

@end
