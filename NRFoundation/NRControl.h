//
//  NRControl.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NRControlAction)(UIControl *sender);


@interface UIControl (NRControl)

- (void)nr_addAction:(NRControlAction)action forControlEvents:(UIControlEvents)controlEvents;
- (void)nr_removeAllBlockActions;

@end

