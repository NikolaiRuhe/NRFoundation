//
//  NRGestureRecognizerAdditions.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NRGestureRecognizerBlockAction)(UIGestureRecognizer *gestureRecognizer);
typedef BOOL (^NRGestureRecognizerShouldBeginBlock)(UIGestureRecognizer *gestureRecognizer);


@interface UIGestureRecognizer (NRGestureRecognizerAdditions)

- (id)nr_initWithBlockAction:(NRGestureRecognizerBlockAction)blockAction __attribute__((objc_method_family(init)));
- (void)nr_addBlockAction:(NRGestureRecognizerBlockAction)blockAction;
- (void)nr_removeBlockActions;

@end
