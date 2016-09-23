//
//  NRActionSheet.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
typedef void (^NRActionSheetAction)(UIActionSheet *actionSheet, NSUInteger buttonIndex);
#pragma clang diagnostic push


@interface UIActionSheet (NRActionSheet)

- (id)nr_initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle action:(NRActionSheetAction)cancelAction destructiveButtonTitle:(NSString *)destructiveButtonTitle action:(NRActionSheetAction)destructiveAction otherButtonTitle:(NSString *)otherButtonTitle action:(NRActionSheetAction)otherAction __attribute__((objc_method_family(init)));

- (NSInteger)nr_addButtonWithTitle:(NSString *)title action:(NRActionSheetAction)action;

- (void)nr_setAction:(NRActionSheetAction)action forButtonAtIndex:(NSUInteger)buttonIndex;

@end
