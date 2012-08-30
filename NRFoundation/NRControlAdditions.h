//
//  NRControlAdditions.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NRControlBlockAction)(UIControl *sender);


@interface UIControl (NRControlAdditions)

- (void)nr_addBlockAction:(NRControlBlockAction)blockAction forControlEvents:(UIControlEvents)controlEvents;
- (void)nr_removeBlockActions;

@end

