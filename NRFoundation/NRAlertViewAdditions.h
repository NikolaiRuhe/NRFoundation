//
//  NRAlertViewAdditions.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NRAlertViewActionBlock)(UIAlertView *alertView, NSUInteger buttonIndex);


@interface UIAlertView (NRAlertViewAdditions)

- (id)nr_initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle action:(NRAlertViewActionBlock)cancelAction otherButtonTitle:(NSString *)otherButtonTitle action:(NRAlertViewActionBlock)otherAction __attribute__((objc_method_family(init)));

- (NSInteger)nr_addButtonWithTitle:(NSString *)title action:(NRAlertViewActionBlock)action;

- (void)nr_setAction:(NRAlertViewActionBlock)action forButtonAtIndex:(NSUInteger)buttonIndex;

@end
