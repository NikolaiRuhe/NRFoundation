//
//  NRAlertView.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
typedef void (^NRAlertViewAction)(UIAlertView *alertView, NSUInteger buttonIndex);
#pragma clang diagnostic push


@interface UIAlertView (NRAlertView)

- (id)nr_initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle action:(NRAlertViewAction)cancelAction otherButtonTitle:(NSString *)otherButtonTitle action:(NRAlertViewAction)otherAction __attribute__((objc_method_family(init)));

- (NSInteger)nr_addButtonWithTitle:(NSString *)title action:(NRAlertViewAction)action;

- (void)nr_setAction:(NRAlertViewAction)action forButtonAtIndex:(NSUInteger)buttonIndex;

@end
