//
//  NRCollections.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-08-01.
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (NRCollections)

#if    (defined(__MAC_OS_X_VERSION_MIN_REQUIRED)  && __MAC_OS_X_VERSION_MIN_REQUIRED  >= 1060)  \
	|| (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000)
#if    (defined(__MAC_OS_X_VERSION_MAX_ALLOWED)   && __MAC_OS_X_VERSION_MAX_ALLOWED   <  1090)  \
    || (defined(__IPHONE_OS_VERSION_MAX_ALLOWED)  && __IPHONE_OS_VERSION_MAX_ALLOWED  <  70000)
// This is public in iOS SDK 7/Mac OS X 10.9 but available from iOS 4/Mac OS 10.6.
// So we declare it here in case an older base SDK is used.
- (id)firstObject;
#endif
#endif

- (NSArray *)nr_map:(id (^)(id element))mapping;

- (NSArray *)nr_filter:(BOOL (^)(id element))filter;

- (id)nr_reduce:(id (^)(id element, id value))reducer;
- (id)nr_reduce:(id (^)(id element, id value))reducer initialValue:(id)initialValue;

@end
