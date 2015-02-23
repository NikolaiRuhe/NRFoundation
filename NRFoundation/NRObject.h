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

// Coalsecing selectors and delayed perform on main thread
- (void)nr_performSelectorCoalescedOnMainThread:(SEL)selector;
- (id)nr_performCoalescedOnMainThread;

@end
