//
//  NRCollections.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-08-01.
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (NRCollections)

- (NSArray *)nr_map:(id (^)(id element))mapping;

- (NSArray *)nr_filter:(BOOL (^)(id element))filter;

- (id)nr_reduce:(id (^)(id element, id value))reducer;
- (id)nr_reduce:(id (^)(id element, id value))reducer initialValue:(id)initialValue;

@end
