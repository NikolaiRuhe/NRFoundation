//
//  NRObject.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <objc/runtime.h>
#import "NRObject.h"

@implementation NSObject (NRObject)

static const char *kNRAsscociatedObjectsKey = "kNRAsscociatedObjectsKey";

- (NSMutableArray *)nr_mutableObjectsForKey:(NSString *)key createIfAbsent:(BOOL)createIfAbsent
{
	NSMutableDictionary *associatedObjects = objc_getAssociatedObject(self, kNRAsscociatedObjectsKey);
	if (associatedObjects == nil) {
		if (! createIfAbsent)
			return nil;
		associatedObjects = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, kNRAsscociatedObjectsKey, associatedObjects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	NSMutableArray *objects = [associatedObjects objectForKey:key];
	if (objects == nil) {
		if (! createIfAbsent)
			return nil;
		objects = [NSMutableArray array];
		[associatedObjects setObject:objects forKey:key];
	}

	return objects;
}

- (NSArray *)nr_objectsForKey:(NSString *)key
{
	return [self nr_mutableObjectsForKey:key createIfAbsent:NO];
}

- (void)nr_addObject:(id)object forKey:(NSString *)key
{
	[[self nr_mutableObjectsForKey:key createIfAbsent:YES] addObject:object];
}

- (void)nr_removeObjectsForKey:(NSString *)key
{
	NSMutableDictionary *associatedObjects = objc_getAssociatedObject(self, kNRAsscociatedObjectsKey);
	if (associatedObjects == nil)
		return;
	[associatedObjects removeObjectForKey:key];
	if ([associatedObjects count] == 0)
		objc_setAssociatedObject(self, kNRAsscociatedObjectsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
