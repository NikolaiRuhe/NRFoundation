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

// Observe notification using a block. Observance lifetime is constrained to NRObserverID and owner, whatever lives longer.
- (NRObserverID)nr_addObserverForName:(NSString *)name object:(id)object owner:(id)owner usingBlock:(void (^)(id owner, NSNotification *notification))block;

// Observe notification using a block. Observance lifetime is constrained to NRObserverID.
- (NRObserverID)nr_addObserverForName:(NSString *)name object:(id)object usingBlock:(void (^)(NSNotification *notification))block;

- (void)nr_removeObserver:(NRObserverID)observerID;

@end
