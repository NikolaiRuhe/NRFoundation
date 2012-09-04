//
//  NRGestureRecognizer.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NRGestureRecognizerAction)(UIGestureRecognizer *gestureRecognizer);
typedef BOOL (^NRGestureRecognizerShouldBeginBlock)(UIGestureRecognizer *gestureRecognizer);


@interface UIGestureRecognizer (NRGestureRecognizer)

- (id)nr_initWithAction:(NRGestureRecognizerAction)action __attribute__((objc_method_family(init)));

- (void)nr_addAction:(NRGestureRecognizerAction)action;

- (void)nr_removeAllBlockActions;

- (void)nr_setShouldBeginBlock:(NRGestureRecognizerShouldBeginBlock)shouldBeginBlock;

@end
