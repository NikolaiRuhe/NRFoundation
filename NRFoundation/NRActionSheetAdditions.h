//
//  NRActionSheetAdditions.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NRActionSheetActionBlock)(UIActionSheet *actionSheet, NSUInteger buttonIndex);


@interface UIActionSheet (NRActionSheetAdditions)

- (id)nr_initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle action:(NRActionSheetActionBlock)cancelAction destructiveButtonTitle:(NSString *)destructiveButtonTitle action:(NRActionSheetActionBlock)destructiveAction otherButtonTitle:(NSString *)otherButtonTitle action:(NRActionSheetActionBlock)otherAction __attribute__((objc_method_family(init)));

- (NSInteger)nr_addButtonWithTitle:(NSString *)title action:(NRActionSheetActionBlock)action;

- (void)nr_setAction:(NRActionSheetActionBlock)action forButtonAtIndex:(NSUInteger)buttonIndex;

@end
