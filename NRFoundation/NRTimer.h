//
//  NRTimer.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-09-04.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NRTimerBlock)(NSTimer *timer);

@interface NSTimer (NRTimer)

+ (NSTimer *)nr_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval userInfo:(id)userInfo repeats:(BOOL)repeats block:(NRTimerBlock)block;

- (id)nr_initWithFireDate:(NSDate *)date interval:(NSTimeInterval)timeInterval userInfo:(id)userInfo repeats:(BOOL)repeats block:(NRTimerBlock)block __attribute__((objc_method_family(init)));

@end
