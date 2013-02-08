//
//  NRNotificationCenter.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-02-08.
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id NRObserverID;

@interface NSNotificationCenter (NRNotificationCenter)

// Add an observer to the notification center which gets automatically removed when it's dealloced.
// By using a weak referencing proxy we make sure notifications are only delivered to objects that are alive.
- (NRObserverID)nr_addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object;

- (NRObserverID)nr_addObserver:(id)observer name:(NSString *)name object:(id)object usingBlock:(void (^)(id observer, NSNotification *notification))block;

- (NRObserverID)nr_addObserverForName:(NSString *)name object:(id)object usingBlock:(void (^)(NSNotification *notification))block;

- (void)nr_removeObserver:(NRObserverID)observerID;

@end
