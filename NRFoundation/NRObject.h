//
//  NRObject.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef id NRKVObserverID;

@interface NSObject (NRObject)

// Lifetime observation
- (void)nr_performAfterDealloc:(void (^)(__unsafe_unretained id object))block;

// KVO
- (NRKVObserverID)nr_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void(^)(id observee, id observer))block;
- (NRKVObserverID)nr_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void(^)(id observee))block;
+ (void)nr_removeObservance:(NRKVObserverID)KVObserverID;

@end
