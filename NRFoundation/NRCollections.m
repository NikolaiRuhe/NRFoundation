//
//  NRCollections.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-08-01.
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#import "NRCollections.h"


@implementation NSArray (NRCollections)

- (NSArray *)nr_map:(id (^)(id element))mapping
{
	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
	for (id element in self) {
		id mappedElement = mapping(element);
		if (mappedElement != nil) {
			[result addObject:mappedElement];
		}
	}
	return result;
}

- (NSArray *)nr_filter:(BOOL (^)(id element))filter
{
	NSMutableArray *result = [[NSMutableArray alloc] init];
	for (id element in self) {
		if (filter(element))
			[result addObject:element];
	}
	return result;
}

- (id)nr_reduce:(id (^)(id element, id value))reducer initialValue:(id)initialValue
{
	id value = initialValue;
	for (id element in self)
		value = reducer(element, value);
	return value;
}

- (id)nr_reduce:(id (^)(id element, id value))reducer
{
	return [self nr_reduce:reducer initialValue:nil];
}

- (id)nr_find:(id (^)(id element))predicate
{
	for (id element in self) {
		id value = predicate(element);
		if (value != nil)
			return value;
	}
	return nil;
}

@end
